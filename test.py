from bluetooth import BluetoothSocket, L2CAP
import time

def discover_devices():
    print("Scanning for devices...")
    nearby_devices = bluetooth.discover_devices(lookup_names=True)
    return nearby_devices

def connect_to_device(target_address):
    port = 17
    sock = BluetoothSocket(L2CAP)

    try:
        sock.connect((target_address, port))
        print(f"Connected to {target_address}")
        return sock
    except Exception as e:
        print(f"Could not connect to {target_address}: {e}")
        return None

def emulate_keyboard_and_type_test(sock):
    if not sock:
        print("No connection to the device.")
        return

    keystrokes = [
        b'\x00\x00\x17\x00\x00\x00\x00\x00',  # T
        b'\x00\x00\x00\x00\x00\x00\x00\x00',  # Release keys
        b'\x00\x00\x08\x00\x00\x00\x00\x00',  # E
        b'\x00\x00\x00\x00\x00\x00\x00\x00',  # Release keys
        b'\x00\x00\x1a\x00\x00\x00\x00\x00',  # S
        b'\x00\x00\x00\x00\x00\x00\x00\x00',  # Release keys
        b'\x00\x00\x20\x00\x00\x00\x00\x00',  # T
        b'\x00\x00\x00\x00\x00\x00\x00\x00'   # Release keys
    ]

    try:
        for report in keystrokes:
            sock.send(report)
            time.sleep(0.1)
        print("Sent 'TEST' keystrokes.")
    except Exception as e:
        print(f"Failed to send keystrokes: {e}")

# Discover devices
devices = discover_devices()
print("Found devices:")
for idx, device in enumerate(devices):
    addr, name = device
    print(f"{idx}: {name} - {addr}")

# Select the target device
device_index = int(input("Enter the index of the target device: "))
target_address = devices[device_index][0]

# Connect to the device
socket = connect_to_device(target_address)

# Emulate keyboard input
emulate_keyboard_and_type_test(socket)

# Close the socket
if socket:
    socket.close()
