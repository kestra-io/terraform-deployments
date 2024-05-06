variable "region" {
  type        = string
  description = "AWS region"
  default     = "eu-west-1"
}

variable "bucket" {
  type        = string
  description = "S3 bucket name"
  default     = "kestra-ie"
}

variable "security_group_name" {
  type        = string
  description = "Security group name"
  default     = "kestra-batch-sg"
  
}

variable "batch_service_role_name" {
  type        = string
  description = "Batch service role name"
  default     = "kestra-batch-service-role"
}

variable "batch_compute_environment_name" {
  type        = string
  description = "Batch compute environment name"
  default     = "kestra-batch-compute-environment"
}

variable "batch_job_queue_name" {
  type        = string
  description = "Batch job queue name"
  default     = "kestra-batch-job-queue"
}

variable "ecs_task_execution_role_name" {
  type        = string
  description = "ECS task execution role name"
  default     = "kestra-ecs-task-execution-role"
}

variable "ecs_task_role_name" {
  type        = string
  description = "ECS task role name"
  default     = "kestra-ecs-task-role"
}

variable "ecs_task_role_policy_name" {
  type        = string
  description = "ECS task role policy name"
  default     = "kestra-ecs-task-role-policy"
}