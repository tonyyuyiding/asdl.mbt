import threading
import sys
import gc

# ============================================================
# 基于 CPython Issue #158312 的崩溃场景构造
#
# 崩溃本质：split-keys 字典的 dk (keys table) 指针在并发访问下
# 被损坏为 0x64（极小非 NULL 地址），导致 _DK_ENTRIES() 解引用时
# 触发 SEGV_MAPERR。
#
# 报告中的崩溃调用链：
#   slot_tp_init → dict.__setitem__ → insertdict
#   → insert_split_key → unicodekeys_lookup_unicode
#   → do_lookup → _DK_ENTRIES (dk=0x64)
#
# 关键特征：
# 1. 发生在类 __init__ 中的 dict 插入操作
# 2. 涉及 split-keys 优化路径（所有键均为 Unicode 字符串）
# 3. 多线程环境（报告时有 7 个线程）
# 4. 可能涉及 free-threading 构建
# ============================================================

print(f"Python version: {sys.version}")
print(f"Free-threading: {not sys._is_gil_enabled() if hasattr(sys, '_is_gil_enabled') else 'N/A'}")
print(f"Thread count: {threading.active_count()}")
print("-" * 50)


class Victim:
    """
    模拟报告中的类初始化场景。

    __init__ 中执行大量 dict.__setitem__ 操作，
    模拟 Hermes Agent 启动时的内部初始化过程。
    所有键均为 Unicode 字符串，触发 split-keys 路径。
    """
    def __init__(self, prefix: str, count: int = 500):
        # 动态生成 Unicode 字符串键，触发 unicodekeys_lookup_unicode
        for i in range(count):
            key = f"{prefix}_attribute_{i}"
            setattr(self, key, i)
            # 显式触发 dict.__setitem__，模拟报告中的调用路径
            self.__dict__[key] = i


# 共享的类级别状态，模拟类初始化期间的全局字典竞争
class GlobalState:
    cache = {}
    _lock = threading.Lock()

    @classmethod
    def insert(cls, key: str, value):
        with cls._lock:
            cls.cache[key] = value


def worker(worker_id: int, iterations: int = 1000):
    """
    工作线程：
    1. 持续创建 Victim 实例（触发 split-keys 字典插入）
    2. 同时向 GlobalState.cache 中并发插入
    3. 周期性触发 GC，增加内存复用压力
    """
    for i in range(iterations):
        # 创建实例 → 触发 slot_tp_init → dict.__setitem__
        obj = Victim(f"w{worker_id}_i{i}", count=50)

        # 并发写入全局字典
        GlobalState.insert(f"w{worker_id}_k{i}", i)

        # 周期性 GC 和内存压力，促使内存块被重用
        if i % 100 == 0:
            gc.collect()

        # 可选：访问属性以触发字典查询路径
        _ = obj.__dict__


def main():
    """
    主线程模拟报告中的场景：主线程阻塞在 epoll_wait（事件循环）中，
    后台线程执行类初始化和字典操作。
    """
    NUM_WORKERS = 7  # 匹配报告中的线程数

    threads = []
    for wid in range(NUM_WORKERS):
        t = threading.Thread(target=worker, args=(wid,), daemon=True)
        t.start()
        threads.append(t)

    # 主线程等待（模拟 epoll_wait 阻塞）
    for t in threads:
        t.join()

    print("Completed without crash (this run).")
    print("Note: Race conditions may require multiple runs or free-threading build.")


if __name__ == "__main__":
    # 增加递归限制，模拟复杂初始化过程
    sys.setrecursionlimit(10000)
    main()