''' 
Code to convert bit file from vivado to a .bin file for embeded linux
'''

import struct
import sys

# import file
d = open(sys.argv[1], 'rb').read()

# jump the prefix, name, part, date and hour
i = 2 + struct.unpack('>H', d[0:2])[0] + 2

for key in b'abcd':
    assert d[i] == key
    i += 3 + struct.unpack('>H', d[i+1:i+3])[0]

assert d[i] == ord('e')

n = struct.unpack('>I', d[i+1:i+5])[0]
raw = d[i+5:i+5+n]
out = b''.join(raw[j:j+4][::-1]
               for j in range(0, len(raw), 4))  # swap bytes

open(sys.argv[2], 'wb').write(out)

# End of File
