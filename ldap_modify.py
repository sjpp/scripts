from ldap3 import Server, Connection, ALL, MODIFY_ADD, MODIFY_REPLACE, SUBTREE
import hashlib
import binascii

def hashit(pwd):
    nthash = hashlib.new('md4', pwd.encode('utf-16le')).digest()
    return nthash

s = Server('freeipa-dev.domain.net', get_info=ALL)
c = Connection(s, user='cn=Directory Manager', password='passwd')
c.bind()

with open('users.txt', 'r') as f:
    for line in f:
        user = line.split("=")[0]
        password = line.split("=")[1]
        ipanthash = hashit(password)
        dn = 'uid='+user+',cn=users,cn=accounts,dc=domain,dc=net'
        c.modify(dn, {'ipaNTHash' : [(MODIFY_ADD, [ipanthash])]})
        c.modify(dn, {'loginShell' : [(MODIFY_REPLACE, ["/bin/bash"])]})
        c.modify(dn, {'krbPasswordExpiration' : [(MODIFY_REPLACE,
                                                  ['20271130122443Z'])]})

c.unbind()
