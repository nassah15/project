resource "aws_iam_policy" "github_actions_eks_describe" {
  name = "github-actions-eks-describe"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["eks:DescribeCluster"]
        Resource = "arn:aws:eks:eu-west-2:755086576117:cluster/ecommerce-eks"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_eks_describe" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_eks_describe.arn
}
