import boto3
import botocore

s3_client = boto3.client('s3')
s3_resource = boto3.resource('s3')

prefixes = s3_client.list_objects(Bucket='niles-security')

def check_exists(key):
    try:
        s3_resource.Object('niles-security', key).load()
    except:
        return False
    return True

for o in prefixes['Contents']:
    key = o['Key']
    try:
        prefix, name = key.split("/")
        correct_prefix = name[0:8]
        if correct_prefix != prefix:
            new_key = f"{correct_prefix}/{name}"
            print(f"Moving {key} to {new_key}")
            #s3_resource.Object('niles-security', new_key).copy_from(CopySource=f'niles-security/{key}')
            if check_exists(new_key):
                print(f"Deleting old key {key}")
                s3_resource.Object('niles-security', key).delete()
            else:
                print("Failed to upload")
    except:
        print(f"key invalid {key}")

        
    

