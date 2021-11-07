from ldap3 import Server, Connection, ALL, MODIFY_ADD, MODIFY_REPLACE, SUBTREE
from python_freeipa import Client
import hashlib

SERVER = 'newipa.domain.net'
DOMAIN = 'domain.net'
ADMIN = 'admin'
ADMIN_PWD = 'passwd'
BINDDN = 'cn=Directory Manager'
BINDDN_PWD = 'passwd'

def hashit(pwd):
    nthash = hashlib.new('md4', pwd.encode('utf-16le')).digest()
    return nthash

client = Client(SERVER, False, None)
client.login(ADMIN, ADMIN_PWD)

with open ('groups.txt', 'r') as g:
    for line in g:
        client.group_add(line.strip("\n"))

with open('all_users.csv', 'r') as f:
    for line in f:
        user = line.split("|")[0]
        first_name = line.split("|")[1]
        last_name = line.split("|")[2]
        full_name = line.split("|")[0]
        mail = line.split("|")[0]
        group = line.split("|")[3]
        u = client.user_add(user, first_name,
                            last_name,
                            full_name,
                            False,
                            mail,
                            None,
                            None,
                            preferred_language='FR')
        g = client.group_add_member(group, user)

s = Server(SERVER, get_info=ALL)
c = Connection(s, user=BINDDN, password=BINDDN_PWD)
c.bind()

with open('all_users.csv', 'r') as f:
    for line in f:
        user = line.split("|")[0]
        password = line.split("|")[4].strip("\n")
        ipanthash = hashit(password)
        dn = 'uid='+user+',cn=users,cn=accounts,dc='+DOMAIN+',dc=fr'
        c.modify(dn, {'krbPasswordExpiration' : [(MODIFY_REPLACE,
                                                  ['20271130122443Z'])]})
        c.modify(dn, {'userPassword' : [(MODIFY_ADD, [password])]})
        c.modify(dn, {'ipaNTHash' : [(MODIFY_ADD, [ipanthash])]})
        c.modify(dn, {'loginShell' : [(MODIFY_REPLACE, ["/bin/bash"])]})

c.unbind()
