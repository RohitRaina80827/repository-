moved {
  from = aws_instance.app
  to   = module.compute.aws_instance.app[0]
}

moved {
  from = aws_instance.status
  to   = module.compute.aws_instance.status[0]
}

