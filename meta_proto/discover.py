from time import time

from api.discover import discover


def main():
    t1 = time()
    result, undiscovered = discover('hmdb', 'HMDB0001134')
    t2 = time()


    print(round(t2-t1),2)
    print("Result:")
    print(result)
    print("Undiscovered:")
    print(undiscovered)


if __name__ == "__main__":
    main()
