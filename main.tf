provider "aws" {
  region = "ap-south-1" 
}
#Security group for EC2

resource "aws_security_group" "ec2_sg"{
    name_prefix = "EC2Securitygroup"



    #SSH access
    ingress{
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    #httpaccess
    ingress{
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    #outboundrules
    egress{
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

}    
#Security group for RDS
resource "aws_security_group" "rds_sg"{
    name_prefix = "RDSSecuritygroup"
    #Inboundrules
    ingress{
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        security_groups = [aws_security_group.ec2_sg.id]
    }
}
#RDS endpoint
locals{
    rds_endpoint = aws_db_instance.rds_instance.endpoint
}

#EC2 instance
resource "aws_instance" "ec2_instance"{
  ami           = "ami-0df6182e39efe7c4d"  
  instance_type = "t4g.micro"
  tags = {
    Name = "EC2Instance"
  }

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  user_data = templatefile("user_data.sh.tpl",
  {
    rds_endpoint = local.rds_endpoint
  }
  )
}

#RDS instance
resource "aws_db_instance" "rds_instance" {
  engine             = "mysql"
  instance_class     = "db.t4g.micro"
  allocated_storage  = 20
  username           = "mydbwp"  
  password           = "mydbwppassword"  
  publicly_accessible = false 

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  tags = {
    Name = "RDSInstance"
  }
}
#outputs
output "ec2_instance_public_ip" {
    value = aws_instance.ec2_instance.public_ip
}
output "rds_endpoint" {
    value = aws_db_instance.rds_instance.endpoint
}
