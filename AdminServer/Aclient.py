
import socket, sys

HOST, PORT = "localhost", 5000
uid = "A6423B"
data = " ".join(sys.argv[1:])
print("data = %s" %data)

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

try :
    sock.connect((HOST,PORT))
    sock.sendall(bytes(uid + " " + data + "\n"))

    recieved = str(sock.recv(1024))

finally :
    sock.close()

print("Sent: {}".format(data))
print("Received: {}".format(recieved))
