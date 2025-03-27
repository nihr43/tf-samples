run: lint
	go run *.go

lint:
	gofmt -w *.go
