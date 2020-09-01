# Terraform Enterprise Workspace Locking/Unlocking Scripts

The two scripts will trigger all workspaces in TFE to be locked for a failover situation.

## Usage

### Lock

```
./lock-workspaces.sh terraform-enterprise-api-token
```

### Unlock

```
./unlock-workspaces.sh terraform-enterprise-api-token
```
