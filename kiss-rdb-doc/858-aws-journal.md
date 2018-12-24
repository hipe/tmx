---
title: aws journal
date: 2018-12-09T02:02:14-05:00
---

## objective & scope of this document

before we knew what kubernetes was and that we wanted it, we knew we wanted
docker and we thought it was a safe bet to start with aws for compute and storage.

this document tracks our first foray into aws (which is scary and
overwhelming, with how many services there are).

also it tracks things up to the point where we decided to put all chips
on kubernetes for now (which itself is out of the scope of this document).




## sign up for aws

we had to give them our CC and a phone number.




## do this tutorial about ecs

do [this turoial from aws about ecs][doc1].

1. they explain the hierarchy of ecs objects:
the container definition is inside the task definition, which is inside the
service, which is inside the cluster.

1. blah blah got the hello world. the interface has changed from what is in
the tutorial, but we were able to figure it out.




## create an IAM user.

following along from [aws doc about getting set up for ECR][doc3].

got a URL like this:

    https://SOME_LARGE_INTEGER.signin.aws.amazon.com/console

put it in your notes.




## install the CLI


follow this [aws doc about installign the CLI][doc2].
we needed at least version 1.9.15 for ECR.

1. get the lastest [CLI](http://aws.amazon.com/cli/).

etc.




## install docker

(got warning about a bunch of pyrsa- scripts not in our path. ignoring.)




## the stuff about docker

the thing about images and layers

read about installing docker

about to run docker

docker ran the "hello world" image in under 5 seconds

goddam getting into an ubuntu shell took like 15 seconds

getting the nginx container running took like 20 seconds

ok let's get it started - making your own image.




## getting started (pt. 2)

## then creating a registry

(began to follow this [aws doc about getting started with ECR][doc4].)




## freeform comments about what happened next..

we had gotten the very basics down about compute, load balancing and so on,
but we didn't feel that we were getting any closer to answering the big
open questions we have (now formalized in [#857] our backend roadmap);
namely, about reading from and writing to some kind of filesystem on the
cloud (suddenly made much more complicated from containers, necessarily)
and also questions about doing system calls (IPC) from a node.

here's a glimpse at our approximate timeline (most recent on top):

|when|what|
|---|---|
|12-16 02:01| got minikube started with `mk start --vm-driver hyperkit`
|12-16 00:53| started k8s tutorials "from the top" (but not the actual top yet)
|12-15 05:22| plot twist: maybe we want k8s "instead" per [some random blog][doc6]
|12-14 07:26| found [docker doc about persistent data volumes][doc5]
|12-11 07:47| part 4: swarms. `docker swarm init` worked
|12-11 07:21| hello world web app ran, now need load balancer
|12-10 02:42| installed docker, now reading getting started


we started googling around for how to do this under kubernetes, and we very
quickly ended up with a deep tangent stack of documents to read, something
like:

    persisten set something
      └ persistent volume claims
        └ persistent volumes
          └ volumes

a lot of our searched pointed us back to the kubernetes documentation, so
although we were familiar with bits and pieces of the concepts we were
finding, we felt that perhaps it was time to approach k8s with more of
a comprehensive "full sweep" approach..




[doc1]: https://aws.amazon.com/getting-started/tutorials/deploy-docker-containers/
[doc2]: https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
[doc3]: https://docs.aws.amazon.com/AmazonECR/latest/userguide/get-set-up-for-amazon-ecr.html
[doc4]: https://docs.aws.amazon.com/AmazonECR/latest/userguide/ECR_GetStarted.html
[doc5]: https://docs.docker.com/docker-for-aws/persistent-data-volumes/
[doc6]: https://www.stratoscale.com/blog/kubernetes/ec2-container-service-vs-kubernetes/ (near) 'For microservice architectures, this creates an additional overhead every service you deploy.'


## (document-meta)

  - #born.
