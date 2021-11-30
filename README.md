### Environment
I have placed a vagrant file in this directory just so everyone can share the 
same environment during development.  

Install [vagrant](https://github.com/hashicorp/vagrant#quick-start)

`vagrant init && vagrant up`

This should expose Nomad and Consul UIs

[http://localhost:4646](http://localhost:4646)   
[http://localhost:8500](http://localhost:8500)

### Install `nomad-pack`
Per [repo](https://github.com/hashicorp/nomad-pack) instructions

### Add registry
`nomad-pack registry add wasmcloud github.com/jordan-rash/wasmcloud-nomad-pack`

### Launch wasmcloud pack
`nomad-pack run --registry=wasmcloud wasmcloud-host`

### Hit washboard

[http://localhost:4000](http://localhost:4000)
