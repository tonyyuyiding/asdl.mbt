a = "before"
_ = "before" # _ is a variable name, but in match case it is special

match "after":
    case a:
        print("a", a)

match "after":
    case _:
        print("_", _)

match [1, 2, 3]:
    case [1, a, _]:
        print(a, _)
    # case [1, b, c]:
    #     print(b, c)
        
match 1:
    case int():
        print("int")
    case str():
        print("str")

match 1:
    case int(x):
        print("int", x)
    case str(x):
        print("str", x)