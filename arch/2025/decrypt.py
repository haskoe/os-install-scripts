def hex_to_string(s):
    return ''.join([chr(int(s[i:i+2],16)) for i in range(0,len(s),2)])

print(hex_to_string('55ea980b'))
