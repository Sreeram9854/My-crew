# My-Terraform Test

1. The set-up is that it creates a VPC, Subnet, RouteTable, InternetGateway and attaches them through route table association
2. Once all the network resources have been set-up then we go ahead and  create a security group
3. The security group is created with only ingress rules for port 80 and port 22 only
4. The EC2 resources are created within the same security group and instance type of t2.micro
5. The EC2 resources also has user_data setup which runs the latest update of the Ubuntu OS 18.04
6. The EC2 resouces also has http installed along with index.xml denoting Server-1 and Server-2
7. An ELB with name "aws_elb" has been created with the listener and health_check properties set-up with target to EC2 servers
8. Finally, a DynamoDB table is created with name "tflocktable" along with read and write capacities
9. The ELB has been tested and it shows both Server-1 and Server-2 in round-robin fashion
10. Also, the Dynamo table with name has been verified from the console.
11. In order to run, you need to input access-key, secret-key, key-name
