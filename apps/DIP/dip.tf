########################
### Aleph to S3 user ###
########################

module "label" {
  source = "github.com/mitlibraries/tf-mod-name?ref=0.12"
  name   = "dip-aleph-S3"
}

module "alephs3" {
  source                 = "github.com/mitlibraries/tf-mod-s3-iam?ref=0.12"
  name                   = "dip-aleph-S3"
  expire_objects_enabled = "true"
  expiration_days        = "60"
}

# Create our AWS user to access the S3 Bucket
resource "aws_iam_user" "default" {
  name          = "${module.label.name}-readwrite"
  path          = "/"
  force_destroy = "false"
  tags          = module.label.tags
}

resource "aws_iam_user_policy_attachment" "default_rw" {
  user       = aws_iam_user.default.name
  policy_arn = module.alephs3.readwrite_arn
}

# Generate API credentials
resource "aws_iam_access_key" "default" {
  user = aws_iam_user.default.name
}

####################################
### Bucket for ASpace harvesting ###
####################################

module "aspace_s3" {
  source                 = "github.com/mitlibraries/tf-mod-s3-iam?ref=0.12"
  name                   = "aspace-oai-s3"
  expire_objects_enabled = "false"
  expiration_days        = "60"
}


################################
### Timdex ES read-only user ###
################################

# Create more restricted read policy for timdex indices
data "aws_iam_policy_document" "read" {
  statement {
    actions = ["es:ESHttpGet"]

    resources = [
      "${module.shared.es_arn}/aleph*",
      "${module.shared.es_arn}/aspace*",
      "${module.shared.es_arn}/production*",
      "${module.shared.es_arn}/timdex*",
    ]
  }
}

module "es-label" {
  source = "github.com/mitlibraries/tf-mod-name?ref=0.12"
  name   = "dip-es-indexes"
}

resource "aws_iam_policy" "es_read" {
  name        = "${module.es-label.name}-read"
  description = "Policy to allow IAM user read only access to DIP ES indexes"
  policy      = data.aws_iam_policy_document.read.json
}

# Create API Credentials for Timdex (Heroku App) to read from Aleph index
module "timdex-es-label" {
  source = "github.com/mitlibraries/tf-mod-name?ref=0.12"
  name   = "timdex-es"
}

resource "aws_iam_user" "timdex" {
  name          = "${module.timdex-es-label.name}-read"
  path          = "/"
  force_destroy = "false"
  tags          = module.timdex-es-label.tags
}

resource "aws_iam_user_policy_attachment" "timdex_es_ro" {
  user       = aws_iam_user.timdex.name
  policy_arn = aws_iam_policy.es_read.arn
}

# Generate API credentials
resource "aws_iam_access_key" "timdex" {
  user = aws_iam_user.timdex.name
}

##############################
### ES Domain Write Policy ###
### Re-evaluate this      ####
#############################

#####################################################################
# Create ES domain policy to allow write access from NAT Public IPs #
# Re-evaluate this when adding indices from other applications    ###
#####################################################################
data "aws_iam_policy_document" "default" {
  statement {
    actions = ["es:*"]

    resources = [
      module.shared.es_arn,
      "${module.shared.es_arn}/*",
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"

      values = module.shared.nat_public_ips
    }
  }
}

resource "aws_elasticsearch_domain_policy" "default" {
  domain_name     = module.shared.es_domain_name
  access_policies = data.aws_iam_policy_document.default.json
}

###################
### Mario below ###
###################

module "mario-label" {
  source = "github.com/mitlibraries/tf-mod-name?ref=0.12"
  name   = "mario"
}

module "ecr" {
  source = "github.com/mitlibraries/tf-mod-ecr?ref=0.12"
  name   = "mario"
}

data "aws_iam_policy_document" "mario_task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "mario_lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"

      identifiers = [
        "lambda.amazonaws.com",
        "ecs-tasks.amazonaws.com",
      ]
    }
  }
}

#########################
### Mario deploy user ###
#########################

data "aws_iam_policy_document" "mario_lambda_s3" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.lambda_s3.arn,
      "${aws_s3_bucket.lambda_s3.arn}/*",
    ]
  }
}

data "aws_iam_policy_document" "mario_lambda_func" {
  statement {
    actions = [
      "lambda:UpdateFunctionCode",
    ]

    resources = [
      aws_lambda_function.default.arn,
    ]
  }
}

resource "aws_iam_policy" "mario_lambda_s3_policy" {
  name        = "${module.mario-label.name}-lambda-s3"
  description = "Policy to allow deploy user to write to mario lambda s3"
  policy      = data.aws_iam_policy_document.mario_lambda_s3.json
}

resource "aws_iam_policy" "mario_lambda_func_policy" {
  name        = "${module.mario-label.name}-lambda-func"
  description = "Policy to allow deploy user to update function code"
  policy      = data.aws_iam_policy_document.mario_lambda_func.json
}

resource "aws_iam_user" "mario_deploy" {
  name = "${module.mario-label.name}-deploy"
  tags = module.mario-label.tags
}

resource "aws_iam_user_policy_attachment" "mario_lambda_s3_attach" {
  user       = aws_iam_user.mario_deploy.name
  policy_arn = aws_iam_policy.mario_lambda_s3_policy.arn
}

resource "aws_iam_user_policy_attachment" "mario_lambda_func_attach" {
  user       = aws_iam_user.mario_deploy.name
  policy_arn = aws_iam_policy.mario_lambda_func_policy.arn
}

resource "aws_iam_user_policy_attachment" "mario_ecr_login_attach" {
  user       = aws_iam_user.mario_deploy.name
  policy_arn = module.ecr.policy_login_arn
}

resource "aws_iam_user_policy_attachment" "mario_ecr_read_attach" {
  user       = aws_iam_user.mario_deploy.name
  policy_arn = module.ecr.policy_read_arn
}

resource "aws_iam_user_policy_attachment" "mario_ecr_write_attach" {
  user       = aws_iam_user.mario_deploy.name
  policy_arn = module.ecr.policy_write_arn
}

resource "aws_iam_access_key" "mario_deploy" {
  user = aws_iam_user.mario_deploy.name
}

###################
### Lambda role ###
###################

data "aws_iam_policy_document" "runtask_policy" {
  statement {
    actions = [
      "ecs:RunTask",
      "iam:PassRole",
      "lambda:InvokeFunction",
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "mario_cloudwatch_policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role" "mario_execution_role" {
  name               = "${module.mario-label.name}-lambda"
  assume_role_policy = data.aws_iam_policy_document.mario_lambda_assume_role.json
  description        = "Role used by Lambda for running mario container"
  tags               = module.mario-label.tags
}

resource "aws_iam_role_policy" "runtask_attach" {
  name   = "${module.mario-label.name}-runtask"
  role   = aws_iam_role.mario_execution_role.name
  policy = data.aws_iam_policy_document.runtask_policy.json
}

resource "aws_iam_role_policy" "mario_cloudwatch_attach" {
  name   = "${module.mario-label.name}-cloudwatch"
  role   = aws_iam_role.mario_execution_role.name
  policy = data.aws_iam_policy_document.mario_cloudwatch_policy.json
}

resource "aws_iam_role_policy_attachment" "mario_ecr_login_attach" {
  role       = aws_iam_role.mario_execution_role.name
  policy_arn = module.ecr.policy_login_arn
}

resource "aws_iam_role_policy_attachment" "mario_ecr_read_attach" {
  role       = aws_iam_role.mario_execution_role.name
  policy_arn = module.ecr.policy_read_arn
}

#########################
### Fargate task role ###
#########################

resource "aws_iam_role" "mario_task_role" {
  name               = "${module.mario-label.name}-task"
  assume_role_policy = data.aws_iam_policy_document.mario_task_assume_role.json
  description        = "Role used by mario Fargate task"
  tags               = module.mario-label.tags
}

resource "aws_iam_role_policy_attachment" "es_read_attach" {
  role       = aws_iam_role.mario_task_role.name
  policy_arn = module.shared.es_read_policy_arn
}

resource "aws_iam_role_policy_attachment" "es_write_attach" {
  role       = aws_iam_role.mario_task_role.name
  policy_arn = module.shared.es_write_policy_arn
}

resource "aws_iam_role_policy_attachment" "s3_read_attach" {
  role       = aws_iam_role.mario_task_role.name
  policy_arn = module.alephs3.readonly_arn
}

######################
### S3 Lambda func ###
######################

resource "aws_s3_bucket" "lambda_s3" {
  bucket = "${module.mario-label.name}-lambda"
  tags   = module.mario-label.tags
}

resource "aws_lambda_permission" "run_lambda" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.default.arn
  principal     = "s3.amazonaws.com"
  source_arn    = module.alephs3.bucket_arn
}

resource "aws_s3_bucket_notification" "default" {
  bucket = module.alephs3.bucket_id

  lambda_function {
    lambda_function_arn = aws_lambda_function.default.arn
    events              = ["s3:ObjectCreated:*"]
  }
}

##############
### Lambda ###
##############

resource "aws_security_group" "default" {
  name        = "${module.mario-label.name}-sg"
  description = "Allow all outband traffic"
  vpc_id      = module.shared.vpc_id

  tags = module.mario-label.tags

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${module.mario-label.name}-lambda"
  retention_in_days = 30
}

resource "aws_lambda_function" "default" {
  function_name = "${module.mario-label.name}-lambda"
  s3_bucket     = aws_s3_bucket.lambda_s3.id
  s3_key        = "mario.zip"
  handler       = "mario-powerup"
  role          = aws_iam_role.mario_execution_role.arn
  description   = "Lambda that starts mario fargate task"
  runtime       = "go1.x"

  environment {
    variables = {
      "ECS_SECURITY_GROUP" = aws_security_group.default.id
      "ECS_SUBNETS"        = join(",", module.shared.private_subnets)
      "ECS_CLUSTER"        = aws_ecs_cluster.default.arn
      "ECS_FAMILY"         = aws_ecs_task_definition.default.family
      "ES_URL"             = "https://${module.shared.es_endpoint}"
    }
  }
}

####################
### Fargate Task ###
####################

resource "aws_ecs_cluster" "default" {
  name = "${module.mario-label.name}-cluster"
  tags = module.mario-label.tags
}

resource "aws_cloudwatch_log_group" "mario" {
  name              = "${module.mario-label.name}-logs"
  retention_in_days = 30
}

data "template_file" "mario_task_template" {
  template = file("${path.module}/task.json")

  vars = {
    image     = module.ecr.registry_url
    log_group = aws_cloudwatch_log_group.mario.name
  }
}

resource "aws_ecs_task_definition" "default" {
  family                   = module.mario-label.name
  container_definitions    = data.template_file.mario_task_template.rendered
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.mario_task_role.arn
  execution_role_arn       = aws_iam_role.mario_execution_role.arn
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
}

