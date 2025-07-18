# https://github.com/cli/cli
alias gh_rate_limit='gh api -H "Accept: application/vnd.github+json" /rate_limit'
# https://github.com/dlvhdr/gh-dash
alias ghdash='gh dash'
alias gh_auth_login="gh auth login --scopes 'project gist repo workflow admin:org'"
# https://github.com/davidraviv/gh-clean-branches
alias git_clean_branches='gh clean-branches'
alias l='ls -l'
alias la='ls -la'
# git
alias gst='git status -sb'
alias gls='git pull --squash origin'
alias git_print_default_branch_github='gh repo view --json defaultBranchRef --jq ".defaultBranchRef.name"'
alias git_origin_url='git remote get-url origin'
alias glds='git pull --squash origin $(git_print_default_branch_github)'
alias gp='git push --follow-tags'
alias gl='git pull --tags'
alias glr='gl --rebase'
alias gco='git checkout'
alias gpf='git push --force'
# go
alias gg='go get'
alias ggu='go get -u'
alias ggua='go get -u ./...'
alias gwi='go work init'
alias gwu='go work use'
alias gmt='go mod tidy'
# piping
alias -g L='| less'
alias -g LL='2>&1 | less'
alias -g N='2 > /dev/null'
alias -g NN='> /dev/null 2>&1'
alias -g G='| grep'
alias -g H='| head'
alias -g T='| tail'
alias -g TF='| tail -f'
alias -g C='| cat'
alias -g F='| fzf'
alias -g W='| wc -l'
alias -g B='| step base64'
alias -g BD='| step base64 -d'
alias -g CB='| clipcopy'
alias -g J='| jq'
alias -g JW='| step crypto jwt inspect --insecure | jq'
# networking
alias nmcvp='nmap -T5 -sC -sV -Pn'
alias network_connections_show='ss -tunlp'
alias network_connections_show_all='ss -antup'
alias network_public_ip='curl -s -4 icanhazip.com && curl -s -6 icanhazip.com'
# rsync from https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/rsync/rsync.plugin.zsh
if type rsync >/dev/null; then
	alias rsync-copy="rsync -avz --progress -h"
	alias rsync-move="rsync -avz --progress -h --remove-source-files"
	alias rsync-update="rsync -avzu --progress -h"
	alias rsync-synchronize="rsync -avzu --delete --progress -h"
	alias cp='rsync-copy'
	alias mv='rsync-move'
fi
# ansible
alias aplay='ansible-playbook'
alias avault='ansible-vault'
# cloud
alias a='aws'
alias asso='aws sso login'
alias aws_get_current_region='aws configure get region || aws configure get region --profile default'
alias aws_export_sso_credentials='eval "$(aws configure export-credentials --format env)"'
alias aws_configure_sso_and_export_credentials='asso && aws_export_sso_credentials'
alias pulumi='pulumi --emoji --color always'
alias p='pulumi'
alias pup='pulumi up'
alias pupy='pulumi up --yes'
alias pry='pulumi refresh --yes'
alias pdestroy='pulumi destroy'
alias pupe='pulumi up --exclude'
alias tfc='terraform -chdir'
# docker
alias d='docker'
alias dspa='docker system prune -a'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias dbl='docker build'
alias dlo='docker logs'
alias dpu='docker pull'
alias drit='docker run -i -t'
alias drir='docker run -i -t --rm'
alias dxc='docker exec'
alias dxci='docker exec -i -t'
alias drm='docker rm'
alias docker_auth_github='gh auth token | docker login ghcr.io --username $(gh config get -h github.com user) --password-stdin'
alias docker_auth_aws='aws ecr get-login-password --region $(aws_get_current_region) | docker login --username AWS --password-stdin $(aws sts get-caller-identity --query Account --output text).dkr.ecr.$(aws_get_current_region).amazonaws.com ; echo -e "${COLOR_REGULAR_RED:-}Consider using https://github.com/awslabs/amazon-ecr-credential-helper?tab=readme-ov-file#docker${COLOR_RESET:-}"'
alias docker_auth_azure='az acr login --name $(az acr list --query "[].name" --output tsv)'
alias docker_auth_gcp='gcloud auth configure-docker ; echo -e "${COLOR_REGULAR_RED:-}Consider using https://github.com/GoogleCloudPlatform/docker-credential-gcr?tab=readme-ov-file#configuration-and-usage${COLOR_RESET:-}"'
alias docker_auth_dockerhub='docker login'
alias docker_image_manipulate='crane'
# docker compose
alias dc='docker compose'
alias docker-compose='docker compose'
alias dcup='docker compose up'
alias dcupb='docker compose up --build'
alias dcupd='docker compose up -d'
alias dcupdb='docker compose up -d --build'
alias dcdn='docker compose down'
alias dcl='docker compose logs'
alias dclf='docker compose logs -f'
# k8s
alias kubectl='kubecolor'
compdef kubecolor=kubectl
alias k='kubectl'
alias h='helm'
alias hf='helmfile'
alias k9='k9s'
alias kn='k9s'
alias st='stern'
alias kaf='kubectl apply -f'
alias kgp='kubectl get pods -o wide'
alias kgpa='kubectl get pods -o wide --all-namespaces'
alias kgpw='kubectl get pods -o wide --watch'
alias kubectl_remove_finalizers="kubectl patch -p '{\"metadata\":{\"finalizers\":null}}' --type merge"
alias kubectl_get_all_sa_with_irsa="kubectl get serviceaccounts --all-namespaces -o json | jq '
  .items
  | map(select(.metadata.annotations.\"eks.amazonaws.com/role-arn\"))
  | sort_by(.metadata.namespace)
  | map({namespace: .metadata.namespace, name: .metadata.name, role_arn: .metadata.annotations.\"eks.amazonaws.com/role-arn\"})
'"
alias kind_create_cluster="kind create cluster"
alias kind_delete_all_clusters="kind delete clusters --all"
alias helm_regitry_login_aws='aws ecr get-login-password --region "$(aws_get_current_region)" | helm registry login --username AWS --password-stdin'
# https://itnext.io/kubernetes-ugly-commands-list-images-and-tags-for-every-container-in-running-pods-4aa2e381522f
alias kubectl_get_all_images="kubectl get pods --field-selector=status.phase==Running -o=json | jq -r '.items[] | \"---\", \"pod_name: \" + .metadata.name, \"Status: \" + .status.phase, \"containers:\", (.spec.containers[] | \"- container_name: \" + .name, \"  image_path: \" + (.image | split(\":\")[0]), \"  image_tag: \" + (.image | split(\":\")[1])), \"---\"'"
alias kubectl_get_all_images_all_ns="kubectl get pods --all-namespaces --field-selector=status.phase==Running -o=json | jq -r '.items[] | \"---\", \"pod_name: \" + .metadata.name, \"Status: \" + .status.phase, \"containers:\", (.spec.containers[] | \"- container_name: \" + .name, \"  image_path: \" + (.image | split(\":\")[0]), \"  image_tag: \" + (.image | split(\":\")[1])), \"---\"'"
# https://itnext.io/kubernetes-ugly-commands-troubleshoot-unready-kustomizations-with-fluxcd-and-gitops-21ba3b63b39
alias kubectl_get_all_flux_not_ready="kubectl get Kustomization.kustomize.toolkit.fluxcd.io -o json | jq -r '.items[] | select (.status.conditions[] | select(.type == \"Ready\" and .status == \"False\")) | \"---\nKustomization Name: \(.metadata.name)\n\nReady Status: \(.status.conditions[] | select(.type == \"Ready\") | \"\n ready: \(.status)\n message: \(.message)\n reason: \(.reason)\n last_transition_time: \(.lastTransitionTime)\")\n\nReconcile Status:\(.status.conditions[] | select(.type == \"Reconciling\") |\"\n reconciling: \(.status)\n message: \(.message)\")\n---\n\"'"
alias kubectl_get_all_flux_not_ready_all_ns="kubectl get Kustomization.kustomize.toolkit.fluxcd.io --all-namespaces -o json | jq -r '.items[] | select (.status.conditions[] | select(.type == \"Ready\" and .status == \"False\")) | \"---\nKustomization Name: \(.metadata.name)\n\nReady Status: \(.status.conditions[] | select(.type == \"Ready\") | \"\n ready: \(.status)\n message: \(.message)\n reason: \(.reason)\n last_transition_time: \(.lastTransitionTime)\")\n\nReconcile Status:\(.status.conditions[] | select(.type == \"Reconciling\") |\"\n reconciling: \(.status)\n message: \(.message)\")\n---\n\"'"
# https://itnext.io/kubernetes-ugly-commands-troubleshoot-pending-pods-in-namespace-c4b2273a1014
alias kubectl_get_all_pending_pods="kubectl get pods --field-selector=status.phase=Pending --no-headers -o json | jq -r '.items[] | \"---\npod_name: \(.metadata.name)\nstatus: \(.status.phase // \"N/A\")\nmessage: \(.status.conditions[].message // \"N/A\")\nreason: \(.status.conditions[].reason // \"N/A\")\ncontainerStatus: \((.status.containerStatuses // [{}])[].state // \"N/A\")\ncontainerMessage: \((.status.containerStatuses // [{}])[].state?.waiting?.message // \"N/A\")\ncontainerReason: \((.status.containerStatuses // [{}])[].state?.waiting?.reason // \"N/A\")\n---\n\"'"
alias kubectl_get_all_pending_pods_all_ns="kubectl get pods --all-namespaces --field-selector=status.phase=Pending --no-headers -o json | jq -r '.items[] | \"---\npod_name: \(.metadata.name)\nstatus: \(.status.phase // \"N/A\")\nmessage: \(.status.conditions[].message // \"N/A\")\nreason: \(.status.conditions[].reason // \"N/A\")\ncontainerStatus: \((.status.containerStatuses // [{}])[].state // \"N/A\")\ncontainerMessage: \((.status.containerStatuses // [{}])[].state?.waiting?.message // \"N/A\")\ncontainerReason: \((.status.containerStatuses // [{}])[].state?.waiting?.reason // \"N/A\")\n---\n\"'"
alias kubectl_delete_all_pods_in_image_pull_back_off_state="kubectl get pods --all-namespaces --ignore-not-found --field-selector 'metadata.namespace!=default' -o custom-columns='STATUS:.status.containerStatuses[*].state.waiting.reason,NAMESPACE:.metadata.namespace,OWNER:.metadata.ownerReferences[0].name' | grep -e 'ImagePullBackOff' -e 'CrashLoopBackOff' | awk '{print \$2, \$3}' | sed 's/-[0-9a-f]*$//' | xargs -n 2 kubectl delete deployment --ignore-not-found -n || echo 'No deployment to delete, you can ignore this message and kubectl strderr above'"
# wireguard
alias wqu='sudo wg-quick up'
alias wqd='sudo wg-quick down'
alias wq='sudo wg-quick'
# node
alias n='npm'
alias ni='npm install'
alias npm_update_dependencies='ncu -u'
alias npm_update_dependencies_and_install='ncu -u && npm install'
# editor
if type nvim >/dev/null; then
	alias vim='nvim'
fi
alias v='vim'
alias vi='vim'
alias nvchad_flush_install='rm -rf ~/.local/share/nvim ; git -C ~/.config/nvim reset --hard HEAD'
alias co="${VISUAL}"
alias cor='co --reuse-window'
alias cr='co --reuse-window'
# SSH
alias s='ssh'
alias sshp='ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no'
# alias ssh_add_key_to_agent='eval $(ssh-agent -s) && ssh-add'
alias ssh_key_fingerprint='ssh-keygen -lf'
# tmux
alias tma='tmux attach-session -t'
# zsh
alias zsh_estimate_startup="hyperfine --warmup 5 --runs 25 --shell=none 'time zsh -i -c exit'"
# https://github.com/sharkdp/hyperfine
alias bench_time='hyperfine --warmup 5 --runs 25 --shell=none'
# debugging
alias keystrokes_show_codes='showkey -a'
# hardware
alias kernel_display_logs='sudo dmesg --follow'
alias hardware_show_info='fastfetch && sudo dmidecode | grep -A10 "^System Information" | sed "/^$/q"'
# miscelanous stuff
alias e='echo'
alias en='echo -n'
if alias x >/dev/null; then
	unalias x
fi
# https://stackoverflow.com/questions/48974448/how-to-generate-a-valid-ula-in-bash
alias network_generate_ipv6_ula='printf "fd%x:%x:%x:%x::/64\n" "$(( ${RANDOM}/256 ))" "${RANDOM}" "${RANDOM}" "${RANDOM}"'
alias gdb='gdb -q'
alias lrc='echo $?'
alias chx='chmod u+x'
alias clr='clear'
alias gleak='gitleaks --no-banner'
alias gleakd='gitleaks --no-banner --no-git'
alias service_status='systemctl --user status'
alias service_status_all='systemctl status'
alias date_current='date +"%Y-%m-%d %H:%M:%S"'
alias cmktemp='TMP_CD_DIR="$(mktemp -d -t shell-tempdir-XXXXXX)" ; if [ -n "${TMP_CD_DIR}" ]; then cd "${TMP_CD_DIR}"; fi ; unset TMP_CD_DIR'
alias mkdir='mkdir -pv'
alias ggr='TMP_CD_DIR="$(git rev-parse --show-toplevel)" ; if [ -n "${TMP_CD_DIR}" ]; then cd "${TMP_CD_DIR}"; fi ; unset TMP_CD_DIR'
alias open='xdg-open'
alias sopse='sops --encrypt --in-place'
alias sopsd='sops --decrypt --in-place'
alias tf='terraform'
alias tfi='terraform init'
alias tfa='terraform apply'
alias tfd='terraform destroy'
alias tfp='terraform plan'
alias tfw='terraform workspace'
