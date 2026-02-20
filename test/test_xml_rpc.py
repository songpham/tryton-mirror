from xmlrpc.client import ServerProxy

# Tryton XML-RPC API
# The endpoint format is: http://host:port/database_name/
# Methods are accessed as: server.type.name.method()
#   - type: 'model', 'wizard', 'report', etc.
#   - name: model name like 'res.user', 'party.party', etc.

# Test connection to Tryton server
try:
    # Connect to the tryton_mirror database with authentication
    # URL format: http://username:password@host:port/database/
    server = ServerProxy('http://admin:admin@localhost:8001/tryton_mirror/', allow_none=True, use_builtin_types=True)
    
    print("Testing Tryton XML-RPC connection...")
    print()
    
    # Test by getting preferences
    print("Getting user preferences...")
    prefs = server.model.res.user.get_preferences(True, {})
    print(f"User preferences: {prefs}")
    print()
    
    # Search for users
    print("Searching for users...")
    user_ids = server.model.res.user.search([], 0, 10, None, {})
    print(f"User IDs: {user_ids}")
    print()
    
    # Read user data
    if user_ids:
        print("Reading user data...")
        users = server.model.res.user.read(user_ids, ['name', 'login'], {})
        for user in users:
            print(f"  - {user.get('name')} (login: {user.get('login')}, id: {user.get('id')})")
    
    print()
    print("XML-RPC connection test successful!")
    
except Exception as e:
    print(f"Error: {e}")
    print("\nMake sure the Tryton server is running:")
    print("  cd projects/grist-core")
    print("  docker-compose up -d tryton-mirror")
    print("  docker-compose logs tryton-mirror")
    print("\nDefault credentials:")
    print("  Username: admin")
    print("  Password: admin")
    print("  Database: tryton_mirror")
