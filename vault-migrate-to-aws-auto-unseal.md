# current configuration
- vault not initialize and sealed
root@vault-node:~# `vault status`
```
Key                Value
---                -----
Seal Type          shamir
Initialized        false
Sealed             true
Total Shares       0
Threshold          0
Unseal Progress    0/0
Unseal Nonce       n/a
Version            1.11.1
Build Date         2022-07-19T20:16:47Z
Storage Type       raft
HA Enabled         true
```

root@vault-node:~# `cat /etc/vault.d/vault.hcl`
```
storage "raft" {
  path    = "/opt/vault/data"
  node_id = "vault-node"
}

listener "tcp" {
 address = "0.0.0.0:8200"
 cluster_address = "0.0.0.0:8201"
 tls_disable = true
}

api_addr = "http://vault-node:8200"
cluster_addr = "http://vault-node:8201"
cluster_name = "vault-node"
ui = true
log_level = "INFO"
disable_mlock = true
```
# assignment
```
Let's go ahead and initialize our Vault node but reduce the number of key shares to 3 and the key thresholds to 2.
As per the below format, store all three unseal keys in the /root/unseal_keys file. Example: - 
Unseal Key 1: <KEY-1>
Unseal Key 2: <KEY-2>
Unseal Key 3: <KEY-3>
and the root token in the /root/main_token file. Example: - 
Initial Root Token: <TOKEN>
```
# solution
root@vault-node:~# `vault operator init --key-shares=3 --key-threshold=2 |tee /root/vault_init`  
root@vault-node:~# `head -3 /root/vault_init > /root/unseal_keys`  
root@vault-node:~# `grep "Initial Root Token /etc/vault_init > /root/main_token`

# assignment
Unseal the Vault node using 2 of the unseal keys from the Vault initialization which we stored in the /root/unseal_keys file.

# solution
root@vault-node:~# `vault operator unseal $(head -1 /root/unseal_keys |awk '{print $4}')`
```
Key                Value
---                -----
Seal Type          shamir
Initialized        true
Sealed             true
Total Shares       3
Threshold          2
Unseal Progress    1/2
Unseal Nonce       2d019245-ae05-78fb-0af1-33f5c10324de
Version            1.11.1
Build Date         2022-07-19T20:16:47Z
Storage Type       raft
HA Enabled         true
```
root@vault-node:~# `vault operator unseal $(tail -1 /root/unseal_keys |awk '{print $4}')`
```
Key                     Value
---                     -----
Seal Type               shamir
Initialized             true
Sealed                  false
Total Shares            3
Threshold               2
Version                 1.11.1
Build Date              2022-07-19T20:16:47Z
Storage Type            raft
Cluster Name            vault-node
Cluster ID              7175eded-3f43-e0f0-91a3-bac1abfe3dce
HA Enabled              true
HA Cluster              n/a
HA Mode                 standby
Active Node Address     <none>
Raft Committed Index    31
Raft Applied Index      31
```
  
# assignment
Log in to Vault using the root token and enable a new KV V2 secrets engine at the path of secrets/.

# solution
root@vault-node:~# export VAULT_TOKEN=`awk '{print $4}' /root/main_token`
root@vault-node:~# vault login $(awk '{print $4}' /root/main_token)
WARNING! The VAULT_TOKEN environment variable is set! The value of this
variable will take precedence; if this is unwanted please unset VAULT_TOKEN or
update its value accordingly.

Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                  Value
---                  -----
token                hvs.qr7j8WDArqego2BQrW3EkQi9
token_accessor       dmYb0RHxU3TCvE0IVtr4Abdb
token_duration       ∞
token_renewable      false
token_policies       ["root"]
identity_policies    []
policies             ["root"]
root@vault-node:~#  `cat .vault-token`
```
hvs.qr7j8WDArqego2BQrW3EkQi9
```
root@vault-node:~# `unset VAULT_TOKEN`
root@vault-node:~# `vault secrets enable --path=secrets/ kv-v2`
```
Success! Enabled the kv-v2 secrets engine at: secrets/
```

# assignment
In the upcoming questions, we will make use of the awskms seal stanza for auto unseal. 
Before going ahead and stop the Vault service so we can make some changes.
# solution
root@vault-node:~# `systemctl stop vault`  

# assignment
Now, let's reconfigure our Vault node so we can migrate from the default seal mechanism to use the AWS auto unseal instead. 
This will allow Vault to automatically unseal itself when the service is restarted. 
In this task, we're going to use an AWS KMS key for auto unseal. 
We have already created a key for you and are available in the /tmp/kms_key file.
Add the below seal stanza to the Vault configuration file: -
```
seal "awskms" {
       region = "us-east-1"
       kms_key_id = "<Enter KMS ARN here>"
   }
```
and don't forget to update the kms_key_id value.

Before going to start the Vault service. We need to provide Vault with AWS credentials to access and use the KMS key. 
Credentials have been created for you already and stored in the /root/AWS_Credentials.txt file and are listed below:

AWS_ACCESS_KEY_ID="AKIA5ECA3SPZDFO2XRUN" 
AWS_SECRET_ACCESS_KEY="HmT3QLiu9bYe5nv46bGuV8h6Zd+knmwlwx5thmH2" 
AWS_REGION="us-east-1"

"Note: - Set these variables on the system environment with the export command. For an example: - 
export AWS_REGION='us-east-1'"

# solution
root@vault-node:~# cat /tmp/kms_key
#Providing AWS ARN for KMS key
{
    "KeyMetadata": {
        "AWSAccountId": "902079157234",
        "KeyId": "57044454-ddd1-4788-aaa1-6a4a15ff6aa2",
        "Arn": "arn:aws:kms:us-east-1:902079157234:key/57044454-ddd1-4788-aaa1-6a4a15ff6aa2",
        "CreationDate": "2022-12-10T20:42:48.577000-05:00",
        "Enabled": true,
        "Description": "",
        "KeyUsage": "ENCRYPT_DECRYPT",
        "KeyState": "Enabled",
        "Origin": "AWS_KMS",
        "KeyManager": "CUSTOMER",
        "CustomerMasterKeySpec": "SYMMETRIC_DEFAULT",
        "KeySpec": "SYMMETRIC_DEFAULT",
        "EncryptionAlgorithms": [
            "SYMMETRIC_DEFAULT"
        ],
        "MultiRegion": false
    }
}

# solution
root@vault-node:~# `cat >> /etc/vault.d/vault.hcl <<EOF`
```                                    
seal "awskms" {
       region = "us-east-1"
       kms_key_id = "arn:aws:kms:us-east-1:902079157234:key/57044454-ddd1-4788-aaa1-6a4a15ff6aa2"
}
```
root@vault-node:~# `cat ~/.aws/credentials`
```
[default]
aws_access_key_id = AKIA5ECA3SPZDFO2XRUN
aws_secret_access_key = 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
```
root@vault-node:~# `systemctl start vault`  
root@vault-node:~# `vault status`
```
Key                           Value
---                           -----
Recovery Seal Type            shamir
Initialized                   true
Sealed                        true
Total Recovery Shares         3
Threshold                     2
Unseal Progress               0/2
Unseal Nonce                  n/a
Seal Migration in Progress    true
Version                       1.11.1
Build Date                    2022-07-19T20:16:47Z
Storage Type                  raft
HA Enabled                    true
```
root@vault-node:~# `vault operator unseal --migrate $(tail -1 /root/unseal_keys |awk '{print $4}')`
```
Key                           Value
---                           -----
Recovery Seal Type            shamir
Initialized                   true
Sealed                        true
Total Recovery Shares         3
Threshold                     2
Unseal Progress               1/2
Unseal Nonce                  b7453a0e-f0e0-f536-cc0b-9f74e1b9eea2
Seal Migration in Progress    true
Version                       1.11.1
Build Date                    2022-07-19T20:16:47Z
Storage Type                  raft
HA Enabled                    true
```
root@vault-node:~# `vault operator unseal --migrate $(head -1 /root/unseal_keys |awk '{print $4}')`
```
Key                           Value
---                           -----
Recovery Seal Type            shamir
Initialized                   true
Sealed                        false
Total Recovery Shares         3
Threshold                     2
Seal Migration in Progress    true
Version                       1.11.1
Build Date                    2022-07-19T20:16:47Z
Storage Type                  raft
Cluster Name                  vault-node
Cluster ID                    7175eded-3f43-e0f0-91a3-bac1abfe3dce
HA Enabled                    true
HA Cluster                    n/a
HA Mode                       standby
Active Node Address           <none>
Raft Committed Index          44
Raft Applied Index            44
```
root@vault-node:~# 

# assignment
Log in to the Vault using the Root token and answer the below question.

How many secret engines are enabled by default?

# solution
root@vault-node:~# `vault login $(awk '{print $4}' main_token)`
```
Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                  Value
---                  -----
token                hvs.qr7j8WDArqego2BQrW3EkQi9
token_accessor       dmYb0RHxU3TCvE0IVtr4Abdb
token_duration       ∞
token_renewable      false
token_policies       ["root"]
identity_policies    []
policies             ["root"]
```
root@vault-node:~# `vault secrets list`
```
Path          Type         Accessor              Description
----          ----         --------              -----------
cubbyhole/    cubbyhole    cubbyhole_0a39d6f7    per-token private secret storage
identity/     identity     identity_4de9678f     identity store
secrets/      kv           kv_789810a7           n/a
sys/          system       system_4faa2591       system endpoints used for control, policy and debugging
root@vault-node:~# 
```
# assignment
After the successful migration to auto unseal, Vault should be automatically unsealed after a service restart. 
Restart the service and check the status of the Vault.

Is Vault unsealed?

# solution
root@vault-node:~# `systemctl stop vault`  
root@vault-node:~# `systemctl start vault`  
root@vault-node:~# `vault secrets list`  
```
Path          Type         Accessor              Description
----          ----         --------              -----------
cubbyhole/    cubbyhole    cubbyhole_0a39d6f7    per-token private secret storage
identity/     identity     identity_4de9678f     identity store
secrets/      kv           kv_789810a7           n/a
sys/          system       system_4faa2591       system endpoints used for control, policy and debugging
```
root@vault-node:~# `vault status`
```
Key                      Value
---                      -----
Recovery Seal Type       shamir
Initialized              true
Sealed                   false
Total Recovery Shares    3
Threshold                2
Version                  1.11.1
Build Date               2022-07-19T20:16:47Z
Storage Type             raft
Cluster Name             vault-node
Cluster ID               7175eded-3f43-e0f0-91a3-bac1abfe3dce
HA Enabled               true
HA Cluster               https://vault-node:8201
HA Mode                  active
Active Since             2022-12-11T02:29:19.216665017Z
Raft Committed Index     69
Raft Applied Index       69
root@vault-node:~# 
```

