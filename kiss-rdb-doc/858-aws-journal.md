---
title: aws journal
date: 2018-12-09T02:02:14-05:00
---

## objective & scope of this document

the undercurrent objective is to be able to make a backend with storage
covering all the (vertical) steps outlined in
our [#857] backend roadmap.

the more specific objective of this document is to (er) document exactly
what we did to get our aws "stuff" up and running, to any extent that we
did to serve our "undercurrent" objective.

to paint the picture in somewhat more detail:
in approaching this broad problem (of "hosting", say),
we're constantly vacillating between

  - aws (amazon) and its many services
  - google cloud (many acronyms) and same
  - heroku and its many add-ons
  - something crazy like openstack

furthermore, we're vacillating between

  - kubernetes (google) along with docker
  - just plain old docker

as such, we try to keep this document focused on "journaling" what we do
with aws, but it will bleed into kubernetes-related things we do _on_ aws.




## sign up for aws

we had to give them our CC and a phone number.
we wanted to do this without a CC if possible, but it was not possible.




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


follow this [aws doc about installing the CLI][doc2].
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




## "log in" (attempt 1)

somehow figured out it is by doing this:
```bash
aws configure
```

and to do that we needed to get an access key.
did that by figuring things out on the web based console.
got a key and secret.




## region

now, there's regions and there's availability zones.

see both described here:

```bash
aws ec2 describe-regions
```
the information returned by the above is interesting, but
it doesn't answer our question (which to use?).

so instead, we read [the aws doc about availability zones][doc8].
here we look at the name of the states in the US (virginia, ohio,
california, oregon) and pick the one that's geographically closest
to our physical working location at the moment:

  - `us-east-2` (ohio)

because that rationale seems to make as much sense as any
(but we aren't sure and should probably read the above document in full).

with `aws configure` again, we enter to accept the defaults of the
first two choices (key and secret), and type the above for the third.




## availability zone

[this explainer from rackspace][doc9] was the first explanation that made
any sense to us about what availability zones are distinct from regions.

but despite having this deeper understanding, it seems we are _not_
expected to pick one (given a region) based on geography: it seems
they are given random mappings per account.


do:
```bash
aws ec2 describe-availability-zones
```

and we see we have to pick one of these:

  - `us-east-2a`, `us-east-2b` or `us-east-2c`

we're gonna pick the first one, because we don't know any better.




## THEN

THEN, WITH THIS COMMAND:
```bash
aws ec2 create-volume \
  --availability-zone us-east-2a \
  --size 1 \
  --volume-type gp2 \
  --dry-run
```

as a startingpoint, the above is based off of an example in
[k8s doc about volumes][doc7]. but we change and enhance the received example
in the following ways:

  - `availability-zone` we changed from `eu-west-1a` to `us-east-2a`
    based partly on randomness and partly on our rambling effors as
    described above.
  - `size` is in GiB (gibibytes (a GiB is ~1.07 billion bytes)).
    we changed it from `10` down to the minimium (`1`), because
    for our initial purposes we expect to need only about
    _3 (three) megabytes_
    (which is about three thousandths of the minimum we can specify).
  - we're sticking with a `volume-type` of `gp2` (as "general purpose" (2 ?))
    as was exampled
    because our use case certainly seems general
    and we don't know any better.
  - (we want to KISS and have no encryption, which we expect is default.)
  - (IOPS (I/O operations per second) shouldn't pertain to us)
  - we indicate `--dry-run` so that you yourself (me, myself) can easily
    do the dry run by copy-pasting all the text of the command as-is.
    (to run it for real, either omit this or change it to `--no-dry-run`.)

HOT!!!
```bash
An error occurred (DryRunOperation) when calling the CreateVolume operation: \
Request would have succeeded, but DryRun flag is set.
```


*_NOTE_* return to [here][doc7] when SOMETHING




[doc1]: https://aws.amazon.com/getting-started/tutorials/deploy-docker-containers/
[doc2]: https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
[doc3]: https://docs.aws.amazon.com/AmazonECR/latest/userguide/get-set-up-for-amazon-ecr.html
[doc4]: https://docs.aws.amazon.com/AmazonECR/latest/userguide/ECR_GetStarted.html
[doc5]: https://docs.docker.com/docker-for-aws/persistent-data-volumes/
[doc6]: https://www.stratoscale.com/blog/kubernetes/ec2-container-service-vs-kubernetes/ "(near) 'For microservice architectures, this creates an additional overhead every service you deploy.'"
[doc7]: https://kubernetes.io/docs/concepts/storage/volumes/
[doc8]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html
[doc9]: https://blog.rackspace.com/aws-101-regions-availability-zones
[doc10_USE_ME]: https://portworx.com/basic-guide-kubernetes-storage/




## (document-meta)

  - #history-A.1: came back to this after a while
  - #born.
