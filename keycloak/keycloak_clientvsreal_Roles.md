What is a Role?

A role defines what a user is allowed to do.

For example:

Admin
    ├── Create schema
    ├── Delete schema
    ├── Manage users
    └── Read data

Developer
    ├── Create schema
    ├── Read data
    └── Update data

Viewer
    └── Read data

When a user logs in, Keycloak includes their roles in the JWT. Your Spring Boot services will read those roles to decide whether to allow an action.

Realm Roles vs Client Roles

This is one of the most confusing topics in Keycloak.

Option 1: Realm Roles

Realm roles are global within a realm.

Example:

Realm: platform

Roles

ADMIN
USER
DEVELOPER
VIEWER

Any client in the platform realm can use these roles.

Example
platform
│
├── platform-gateway
├── platform-ui
├── postman
│
Realm Roles
│
├── ADMIN
├── USER
├── VIEWER
└── DEVELOPER

These roles appear in the JWT like:

"realm_access": {
  "roles": [
    "ADMIN",
    "USER"
  ]
}
Option 2: Client Roles

Client roles belong to a specific client.

Example:

platform-gateway

Roles

READ_SCHEMA
WRITE_SCHEMA
DELETE_SCHEMA

These appear in the JWT under:

"resource_access": {
  "platform-gateway": {
    "roles": [
      "READ_SCHEMA"
    ]
  }
}
