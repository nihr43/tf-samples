export NIXPKGS_ALLOW_UNFREE := "1"

apply: lint
  nix-shell -p terraform --run 'terraform apply'

lint:
  nix-shell -p terraform --run 'terraform fmt'

destroy:
  incus stop --all
  nix-shell -p terraform --run 'terraform destroy'
