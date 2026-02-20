from proteus import Model, config

# Connect to Tryton
# Format: http://username:password@host:port/database_name/
try:
    config.set_xmlrpc('http://admin:admin@localhost:8001/tryton_mirror/')
    
    print("Connected to Tryton successfully!")
    print()
    
    # Access models - try to get the User model
    User = Model.get('res.user')
    users = User.find(limit=5)
    print(f"Found {len(users)} users:")
    for user in users:
        print(f"  - {user.name} (ID: {user.id})")
    
except Exception as e:
    print(f"Error: {e}")
    print("\nMake sure the Tryton server is running and initialized:")
    print("  cd projects/grist-core")
    print("  docker-compose up -d tryton-mirror")
    print("  docker-compose logs tryton-mirror")
    print("\nDefault credentials:")
    print("  Username: admin")
    print("  Password: admin")
    print("  Database: tryton_mirror")
