class AddressIPv4:
    def __init__(self, address: str):
        if not self.is_valid(address):
            raise ValueError(f"Invalid IPv4 address: {address}")
        self.address = address
    
    @staticmethod
    def is_valid(address: str) -> bool:
        parts = address.split('.')
        if len(parts) != 4:
            return False
        for part in parts:
            if not part.isdigit() or not 0 <= int(part) <= 255:
                return False
        return True

    def to_binary(self) -> str:
        return '.'.join(format(int(part), '08b') for part in self.address.split('.'))

    def __str__(self):
        return self.address

    def __eq__(self, other):
        if isinstance(other, AddressIPv4):
            return self.address == other.address
        return False


try:
    ip1 = AddressIPv4("192.168.1.1")
    print(f"Valid IP: {ip1}")
    print(f"Binary representation: {ip1.to_binary()}")

    ip2 = AddressIPv4("256.100.50.25")  
except ValueError as e:
    print(e)

try:
    ip3 = AddressIPv4("10.0.0.255")
    print(f"Valid IP: {ip3}")
    print(f"Binary representation: {ip3.to_binary()}")

    print(ip1 == ip3)  # False
    ip4 = AddressIPv4("192.168.1.1")
    print(ip1 == ip4)  # True
except ValueError as e:
    print(e)
