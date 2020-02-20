import queue

Q = queue.SimpleQueue()
Q.put(1)
Q.put(2)
Q.put(3)


print(Q.get())
print(Q.get())
print(Q.get())
