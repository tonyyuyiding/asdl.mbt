def f():
    match "after":
        case a:
            pass
    match "after":
        case _:
            pass
            
import dis
dis.dis(f)