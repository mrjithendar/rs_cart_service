@Library("roboshop@master") _

pipeline {

    agent any

    environment {
        tfDir = "terraform"
        region = "us-east-1"
        AWSCreds = credentials('awsCreds')
        AWS_ACCESS_KEY_ID = "${AWSCreds_USR}"
        AWS_SECRET_ACCESS_KEY = "${AWSCreds_PSW}"
        vault = credentials('vaultToken')
        tfvars = "vars/${params.Options}.tfvars"
        eks_cluster_name = "roboshop-eks-cluster-int"
    }

    stages {

        stage('Vars from Shred Library') {
            steps {
                script {
                    helloWorld('Decode', 'DevOps')
                    aWs()
                }
            }
        }

        stage('Check Vars') {
            steps {
                sh "echo AWS_ACCOUNT_ID"
            }
        }


        // stage ('Docker Login') {
        //     steps {
        //         sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
        //     }
        // }

        // stage ("Build Cart Docker Image") {
        //         steps {
        //             dir("Docker/cart") {
        //                 sh "docker build -t roboshop-cart-int ."
        //                 sh "docker tag roboshop-cart-int:latest ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/roboshop-cart-int:latest"
        //                 sh "docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/roboshop-cart-int:latest"
        //         }
        //     }
        // }
    }
}
