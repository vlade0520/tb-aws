resource "aws_iam_role" "aws_lz_gft_eks_iam_role" {
  name = var.eks_iam_role_name #"eks-cluster-ingress-role"

  assume_role_policy = var.eks_user_policy
}

resource "aws_iam_role_policy_attachment" "aws_lz_gft_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.aws_lz_gft_eks_iam_role.name
}

resource "aws_iam_role_policy_attachment" "aws_lz_gft_AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.aws_lz_gft_eks_iam_role.name
}

resource "aws_eks_cluster" "eks_ingress_cluster" {
  name     = var.eks_cluster_name #"eks_ingress_cluster"
  role_arn = aws_iam_role.aws_lz_gft_eks_iam_role.arn

  vpc_config {
    #subnet_ids = ["${aws_subnet.example1.id}", "${aws_subnet.example2.id}"]
    subnet_ids = var.subnets
  }

  depends_on = [
    aws_iam_role_policy_attachment.aws_lz_gft_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.aws_lz_gft_AmazonEKSServicePolicy,
  ]
}