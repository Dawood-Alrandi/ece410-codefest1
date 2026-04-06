# Simple AI search example

def heuristic(a, b):
    return abs(a - b)

def a_star(start, goal):
    print(f"Searching from {start} to {goal}")
    return ["start", "goal"]

if __name__ == "__main__":
    path = a_star(0, 10)
    print("Path:", path)
