// allow nomad-pack to set the job name

[[- define "job_name" -]]
[[- if eq .wasmcloud.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .wasmcloud.job_name | quote -]]
[[- end -]]
[[- end -]]

// only deploys to a region if specified

[[- define "region" -]]
[[- if not (eq .wasmcloud.region "") -]]
region = [[ .wasmcloud.region | quote]]
[[- end -]]
[[- end -]]
