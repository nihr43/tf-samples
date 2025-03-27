`main.go` shows how to wrap terraform and pull useful values out of the resulting state.

We then use these values to demonstrate a basic healthcheck after deployment.

```
tf-samples > just
gofmt -w *.go
go run *.go
Applying Terraform changes...
Terraform apply complete
instance alpine-asdf has ip 10.38.154.207
10.38.154.207 responds
instance alpine-qwer has ip 10.38.154.16
10.38.154.16 responds
instance alpine-zxcv has ip 10.38.154.23
10.38.154.23 responds
```
