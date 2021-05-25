# Terraform ECS Application

This module generate all core resources of ECS Application. you can use with Application load balancer and deploy securely with [CodeDeploy](https://aws.amazon.com/pt/codedeploy/).

## Inspiration

We used these public modules to generate this module in a single one resource module:

* [ECS service from Trussworks](https://registry.terraform.io/modules/trussworks/ecs-service/aws/latest)
* [Official alb module from AWS](https://registry.terraform.io/modules/terraform-aws-modules/alb/aws/latest)
* [CodeDeploy ECS from Faros-AI](https://registry.terraform.io/modules/faros-ai/codedeploy-for-ecs/aws/latest)

This modules are **excelents**, but we need to customize some itens.

* Guarantee all resources to receive our tags (we use Billing Tags)
* Simplify complexibility from module consumers the responsibility to create target groups for CodeDeploy
* Integrate CodeDeploy with uniformity in all applications (we plan to use this module in varios applications)
* Remove responsability of customize Autoscaling policy from ECS Application module (We need to use some custom rules for scaling policies)
* Change loop interaction from `count` to `for_each` (for_each is better)
* Convert some variables from list(some_type) to set(some_type) (sets are immutable when change order of the elements)
* Converge all decision in a single `locals` block (better to manage changes and code review)

## Features inner this module

* Runs an ECS service with or without an AWS load balancer.
* Stream logs to a CloudWatch log group encrypted with a KMS key.
* Create BLUE/GREEN target groups to connect in multiples Listeners in a Application Load Balancers (ALB).
* Run deploy under Canary or Linear or Blue/Green Deployments under CodeDeploy.
* Plug Code deploy with Custom Lambda Function to enable Traffic using functional Tests.

![simple-diagram](docs/module-content.jpg)

## Terraform Versions

Terraform 0.15+. Pin module version to ~> 6.0. Submit pull-requests to master branch.

## Usage

### ECS service associated with an Application Load Balancer (ALB) and CodeDeploy

```hcl
module "ecs-service" {
  source = "pagarme/ecs-application/aws"

  name            = "my web application"
  ecs_cluster     = aws_ecs_cluster.my_cluster
  environment     = "production"
  container_port  = 3000
  ecs_use_fargate = true

  load_balancer = {
    # arn of the load balancer (Application Load Balancer)
    alb_arn                           = aws_lb.my_load_balancer.arn
    # main container name from task definition
    container_name                    = "hello_world"
    # security group of the load balancer (rules will be added from module)
    alb_security_group_id             = aws_security_group.my_load_balancer.id
    # listener to use for blue/green targets
    production_listener_arn           = aws_lb_listener.http.arn
    # Time in seconds do wait container to be ready for connections
    health_check_grace_period_seconds = null
    # All properties from lb_target_group (except health_check) will be passed here
    target_group_additional_options   = {}
    # listener for test before enable traffic
    testing_listener = {
      # port to use for tests in traffic shift (the test listener will be created inner module)
      port            = local.testing_port
      #testing listener protocol
      protocol        = local.protocol
      #testing listener ssl policy (if https)
      ssl_policy      = null
      # you can use certificate to associate with Test listener (if https)
      certificate_arn = null
    }
    # you can use all configuration from health_check property from lb_target_group resource
    health_check = {
      timeout             = 5
      interval            = 30
      path                = "/health"
      protocol            = "HTTP"
      healthy_threshold   = 3
      unhealthy_threshold = 3
      matcher             = "200-399"
    }
  }

  # only if deployment_controller = CODE_DEPLOY, codedeploy will be created
  deployment = {
    description                      = "deployer"
    deployment_controller            = "CODE_DEPLOY"
    deployment_config_name           = "CodeDeployDefault.ECSCanary10Percent5Minutes"
    auto_rollback_enabled            = true
    auto_rollback_events             = ["DEPLOYMENT_FAILURE"]
    action_on_timeout                = "STOP_DEPLOYMENT"
    wait_time_in_minutes             = 20
    termination_wait_time_in_minutes = 20
  }

  container_definitions = <<TASK DEFINITION HERE>>

  cloudwatch = {
    prefix_name       = local.log_prefix
    retention_in_days = 7
  }

  networking = {
    subnet_ids       = local.subnet_ids
    vpc_id           = local.vpc_id
    assign_public_ip = true
  }

  tags = local.tags # we pass any string map and will be added in all resources.
}

```

### ECS service associated with an Application Load Balancer (ALB) and CodeDeploy without Testing Listener

```hcl
module "ecs-service" {
  source = "pagarme/ecs-application/aws"

  name            = "my web application"
  ecs_cluster     = aws_ecs_cluster.my_cluster
  environment     = "production"
  container_port  = 3000
  ecs_use_fargate = true

  load_balancer = {
    # arn of the load balancer (Application Load Balancer)
    alb_arn                           = aws_lb.my_load_balancer.arn
    # main container name from task definition
    container_name                    = "hello_world"
    # security group of the load balancer (rules will be added from module)
    alb_security_group_id             = aws_security_group.my_load_balancer.id
    # listener to use for blue/green targets
    production_listener_arn           = aws_lb_listener.http.arn
    # Time in seconds do wait container to be ready for connections
    health_check_grace_period_seconds = null
    # All properties from lb_target_group (except health_check) will be passed here
    target_group_additional_options   = {}
    # you can use all configuration from health_check property from lb_target_group resource
    health_check = {
      timeout             = 5
      interval            = 30
      path                = "/health"
      protocol            = "HTTP"
      healthy_threshold   = 3
      unhealthy_threshold = 3
      matcher             = "200-399"
    }
  }

  # only if deployment_controller = CODE_DEPLOY, codedeploy will be created
  deployment = {
    description                      = "deployer"
    deployment_controller            = "CODE_DEPLOY"
    deployment_config_name           = "CodeDeployDefault.ECSCanary10Percent5Minutes"
    auto_rollback_enabled            = true
    auto_rollback_events             = ["DEPLOYMENT_FAILURE"]
    action_on_timeout                = "STOP_DEPLOYMENT"
    wait_time_in_minutes             = 20
    termination_wait_time_in_minutes = 20
  }

  container_definitions = <<TASK DEFINITION HERE>>

  cloudwatch = {
    prefix_name       = local.log_prefix
    retention_in_days = 7
  }

  networking = {
    subnet_ids       = local.subnet_ids
    vpc_id           = local.vpc_id
    assign_public_ip = true
  }

  tags = local.tags # we pass any string map and will be added in all resources.
}

```

### ECS service associated WITHOUT Application Load Balancer (ALB) and WITHOUT CodeDeploy

```hcl
module "ecs-service" {
  source = "pagarme/ecs-application/aws"

  name            = "my web application"
  ecs_cluster     = aws_ecs_cluster.my_cluster
  environment     = "production"
  container_port  = 3000
  ecs_use_fargate = true

  # if no load_balancer definition, we don't create any resource (targets and test listener)

  container_definitions = <<TASK DEFINITION HERE>>


  # without load balancer we cant manage shift of the versions

  cloudwatch = {
    prefix_name       = local.log_prefix
    retention_in_days = 7
  }

  networking = {
    subnet_ids       = local.subnet_ids
    vpc_id           = local.vpc_id
    assign_public_ip = true
  }

  tags = local.tags # we pass any string map and will be added in all resources.
}
```

## Limitations (Some limitations we be solved later)

* Only with load balancer, we have CodeDeploy
* If you will use Service Discovery from AWS, we can't help you with CodeDeploy (AWS Limitation?)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_codedeploy_app.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codedeploy_app) | resource |
| [aws_codedeploy_deployment_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codedeploy_deployment_group) | resource |
| [aws_ecs_service.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_policy.codedeploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.codedeploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.task_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.task_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.instance_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.task_execution_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.codedeploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lb_listener.testing_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_target_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_security_group.ecs_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.app_ecs_allow_conn_from_container_to_alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.app_ecs_allow_outbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_ecs_task_definition.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecs_task_definition) | data source |
| [aws_iam_policy_document.assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecs_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.instance_role_policy_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.policy_deployer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.task_execution_role_policy_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_security_group_ids"></a> [additional\_security\_group\_ids](#input\_additional\_security\_group\_ids) | In addition to the security group created for the service, a list of security groups the ECS service should also be added to. | `set(string)` | `[]` | no |
| <a name="input_cloudwatch"></a> [cloudwatch](#input\_cloudwatch) | cloudwatch configuration block | <pre>object({<br>    prefix_name       = string<br>    retention_in_days = number<br>  })</pre> | <pre>{<br>  "prefix_name": "/ecs/fargate",<br>  "retention_in_days": 7<br>}</pre> | no |
| <a name="input_container_definitions"></a> [container\_definitions](#input\_container\_definitions) | Container definitions provided as valid JSON document. Default uses golang:alpine running a simple hello world. | `string` | n/a | yes |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | port used by conteiner service instantiated | `number` | n/a | yes |
| <a name="input_deployment"></a> [deployment](#input\_deployment) | Deployment configuration, deployment resources will be created if deployment\_controller is CODE\_DEPLOY | <pre>object({<br>    description                      = string<br>    deployment_controller            = string<br>    deployment_config_name           = string<br>    auto_rollback_enabled            = bool<br>    auto_rollback_events             = set(string)<br>    action_on_timeout                = string<br>    wait_time_in_minutes             = number<br>    termination_wait_time_in_minutes = number<br>  })</pre> | <pre>{<br>  "action_on_timeout": "STOP_DEPLOYMENT",<br>  "auto_rollback_enabled": true,<br>  "auto_rollback_events": [<br>    "DEPLOYMENT_FAILURE"<br>  ],<br>  "deployment_config_name": null,<br>  "deployment_controller": "ECS",<br>  "description": "deployer",<br>  "termination_wait_time_in_minutes": 20,<br>  "wait_time_in_minutes": 20<br>}</pre> | no |
| <a name="input_ecr_repo_arns"></a> [ecr\_repo\_arns](#input\_ecr\_repo\_arns) | The ARNs of the ECR repos.  By default, allows all repositories. | `set(string)` | <pre>[<br>  "*"<br>]</pre> | no |
| <a name="input_ecs_cluster"></a> [ecs\_cluster](#input\_ecs\_cluster) | ECS cluster object for this task. | <pre>object({<br>    arn  = string<br>    name = string<br>  })</pre> | n/a | yes |
| <a name="input_ecs_instance_role"></a> [ecs\_instance\_role](#input\_ecs\_instance\_role) | The name of the ECS instance role. | `string` | `""` | no |
| <a name="input_ecs_use_fargate"></a> [ecs\_use\_fargate](#input\_ecs\_use\_fargate) | Whether to use Fargate for the task definition. | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment tag, e.g prod. | `string` | n/a | yes |
| <a name="input_fargate_options"></a> [fargate\_options](#input\_fargate\_options) | Fargate options for ECS fargate task | <pre>object({<br>    platform_version = string<br>    task_cpu         = number<br>    task_memory      = number<br>  })</pre> | <pre>{<br>  "platform_version": "1.4.0",<br>  "task_cpu": 256,<br>  "task_memory": 512<br>}</pre> | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | KMS customer managed key (CMK) ARN for encrypting application logs. | `string` | `""` | no |
| <a name="input_load_balancer"></a> [load\_balancer](#input\_load\_balancer) | load balancer information | <pre>object({<br>    alb_arn                 = string<br>    container_name          = string<br>    alb_security_group_id   = string<br>    production_listener_arn = string<br>    production_listener_rules = map(object({<br>      priority   = number<br>      actions    = set(any)<br>      conditions = set(any)<br>    }))<br>    testing_listener = object({<br>      port            = number<br>      protocol        = string<br>      certificate_arn = string<br>      ssl_policy      = string<br>    })<br>    health_check_grace_period_seconds = number<br>    target_group_additional_options   = map(any)<br>    health_check = object({<br>      healthy_threshold   = number<br>      interval            = number<br>      matcher             = string<br>      path                = string<br>      protocol            = string<br>      timeout             = number<br>      unhealthy_threshold = number<br>    })<br>  })</pre> | <pre>{<br>  "alb_arn": null,<br>  "alb_security_group_id": null,<br>  "container_name": null,<br>  "health_check": {<br>    "healthy_threshold": 3,<br>    "interval": 30,<br>    "matcher": "200-299",<br>    "path": "/",<br>    "protocol": "HTTP",<br>    "timeout": 10,<br>    "unhealthy_threshold": 3<br>  },<br>  "health_check_grace_period_seconds": null,<br>  "production_listener_arn": null,<br>  "production_listener_rules": {<br>    "main": {<br>      "actions": [],<br>      "conditions": [],<br>      "priority": 10<br>    }<br>  },<br>  "target_group_additional_options": {},<br>  "testing_listener": {<br>    "certificate_arn": null,<br>    "port": -1,<br>    "protocol": "HTTP",<br>    "ssl_policy": null<br>  }<br>}</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | The service name. | `string` | n/a | yes |
| <a name="input_networking"></a> [networking](#input\_networking) | network configuration for the service | <pre>object({<br>    vpc_id           = string<br>    subnet_ids       = set(string)<br>    assign_public_ip = bool<br>  })</pre> | n/a | yes |
| <a name="input_service_registries"></a> [service\_registries](#input\_service\_registries) | List of service registry objects as per <https://www.terraform.io/docs/providers/aws/r/ecs_service.html#service_registries-1>. List can only have a single object until <https://github.com/terraform-providers/terraform-provider-aws/issues/9573> is resolved. | <pre>set(object({<br>    registry_arn   = string<br>    container_name = string<br>    container_port = number<br>    port           = number<br>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | tags for resources | `map(string)` | <pre>{<br>  "module": "terraform-ecs-application"<br>}</pre> | no |
| <a name="input_tasks_desired_count"></a> [tasks\_desired\_count](#input\_tasks\_desired\_count) | The number of instances of a task definition. | `number` | `1` | no |
| <a name="input_tasks_maximum_percent"></a> [tasks\_maximum\_percent](#input\_tasks\_maximum\_percent) | Upper limit on the number of running tasks. | `number` | `200` | no |
| <a name="input_tasks_minimum_healthy_percent"></a> [tasks\_minimum\_healthy\_percent](#input\_tasks\_minimum\_healthy\_percent) | Lower limit on the number of running tasks. | `number` | `100` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_awslogs_group"></a> [awslogs\_group](#output\_awslogs\_group) | Name of the CloudWatch Logs log group containers should use. |
| <a name="output_awslogs_group_arn"></a> [awslogs\_group\_arn](#output\_awslogs\_group\_arn) | ARN of the CloudWatch Logs log group containers should use. |
| <a name="output_blue_target_group"></a> [blue\_target\_group](#output\_blue\_target\_group) | (Application Load Balancer) production target groups |
| <a name="output_codedeploy_app_id"></a> [codedeploy\_app\_id](#output\_codedeploy\_app\_id) | (CodeDeploy) Amazon's assigned ID for the application. |
| <a name="output_codedeploy_app_name"></a> [codedeploy\_app\_name](#output\_codedeploy\_app\_name) | (CodeDeploy) The application's name. |
| <a name="output_codedeploy_deployment_group_id"></a> [codedeploy\_deployment\_group\_id](#output\_codedeploy\_deployment\_group\_id) | (CodeDeploy) Application name and deployment group name. |
| <a name="output_codedeploy_iam_policy_arn"></a> [codedeploy\_iam\_policy\_arn](#output\_codedeploy\_iam\_policy\_arn) | (CodeDeploy) The ARN assigned by AWS to this IAM Policy. |
| <a name="output_codedeploy_iam_policy_id"></a> [codedeploy\_iam\_policy\_id](#output\_codedeploy\_iam\_policy\_id) | (CodeDeploy) The IAM Policy's ID. |
| <a name="output_codedeploy_iam_policy_name"></a> [codedeploy\_iam\_policy\_name](#output\_codedeploy\_iam\_policy\_name) | (CodeDeploy) The name of the IAM Policy. |
| <a name="output_codedeploy_iam_role_arn"></a> [codedeploy\_iam\_role\_arn](#output\_codedeploy\_iam\_role\_arn) | (CodeDeploy) The Amazon Resource Name (ARN) specifying the IAM Role. |
| <a name="output_codedeploy_iam_role_name"></a> [codedeploy\_iam\_role\_name](#output\_codedeploy\_iam\_role\_name) | (CodeDeploy) The name of the IAM Role. |
| <a name="output_ecs_security_group_id"></a> [ecs\_security\_group\_id](#output\_ecs\_security\_group\_id) | Security Group ID assigned to the ECS tasks. |
| <a name="output_green_target_group"></a> [green\_target\_group](#output\_green\_target\_group) | (Application Load Balancer) production target groups |
| <a name="output_service_arn"></a> [service\_arn](#output\_service\_arn) | service identification ARN |
| <a name="output_task_definition_arn"></a> [task\_definition\_arn](#output\_task\_definition\_arn) | Full ARN of the Task Definition (including both family and revision). |
| <a name="output_task_definition_family"></a> [task\_definition\_family](#output\_task\_definition\_family) | The family of the Task Definition. |
| <a name="output_task_execution_role"></a> [task\_execution\_role](#output\_task\_execution\_role) | The role object of the task execution role that the Amazon ECS container agent and the Docker daemon can assume. |
| <a name="output_task_execution_role_arn"></a> [task\_execution\_role\_arn](#output\_task\_execution\_role\_arn) | The ARN of the task execution role that the Amazon ECS container agent and the Docker daemon can assume. |
| <a name="output_task_execution_role_name"></a> [task\_execution\_role\_name](#output\_task\_execution\_role\_name) | The name of the task execution role that the Amazon ECS container agent and the Docker daemon can assume. |
| <a name="output_task_role"></a> [task\_role](#output\_task\_role) | The IAM role object assumed by Amazon ECS container tasks. |
| <a name="output_task_role_arn"></a> [task\_role\_arn](#output\_task\_role\_arn) | The ARN of the IAM role assumed by Amazon ECS container tasks. |
| <a name="output_task_role_name"></a> [task\_role\_name](#output\_task\_role\_name) | The name of the IAM role assumed by Amazon ECS container tasks. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

**NOTE:** Best practice is to use a separate KMS key per ECS Service. Do not re-use KMS keys if it can be avoided.

## Developer Setup

Install dependencies (macOS)

```shell
brew install pre-commit go terraform terraform-docs
```

### Testing

[Terratest](https://github.com/gruntwork-io/terratest) is being used for
automated testing with this module. Tests in the `test` folder can be run
locally by running the following command:

```text
make test
```

Or with aws-vault:

```text
AWS_VAULT_KEYCHAIN_NAME=<NAME> aws-vault exec <PROFILE> -- make test
```
