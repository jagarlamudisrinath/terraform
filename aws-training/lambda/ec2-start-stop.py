import boto3

region = 'us-east-1'
ec2 = boto3.client('ec2', region_name=region)

def get_instances(tag_name, value):
    instances = []
    response = ec2.describe_instances()
    for reservation in response["Reservations"]:
        for instance in reservation["Instances"]:
            # This sample print will output entire Dictionary object
            for tag in instance["Tags"]:
                if tag['Key'] == tag_name:
                    if tag['Value'] == value:
                        instances.append(instance["InstanceId"])
    return instances

def instance_start(instances):
    ec2.start_instances(InstanceIds=instances)
    print('started your instances: ' + str(instances))


def instance_stop(instances):
    ec2.stop_instances(InstanceIds=instances)
    print('stopped your instances: ' + str(instances))


def main(event, context):
    instances = get_instances(tag_name="Scheduled",value="Yes")
    print(instances)
    if instances != []:
        if event['Action'] == 'Stop':
            instance_stop(instances)
        elif event['Action'] == 'Start':
            instance_start(instances)
        else:
            pass
    print("noinstances selected")
