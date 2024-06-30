#!/usr/bin/env -S buildah unshare bash -ev

run="buildah run -v $PWD:/root/netscape:Z"

# we need an rpm that will install old packages, this will do
el=$(buildah from almalinux:8-minimal)

# install rpms, skip scripts because they bug out
ROOT=/root/netscape-root
buildah config --workingdir /root/netscape/rpms $el
$run $el rpm -vr $ROOT -i --nodeps --noscripts \*.rpm

# need to do this because we used --noscripts
mv $(buildah mount $el)$ROOT/usr/X11R6/lib/lib* \
$(buildah mount $el)$ROOT/usr/lib/
$run $el chroot $ROOT /sbin/ldconfig

# trim some stuff
find $(buildah mount $el)$ROOT -depth -type d -print0|\
xargs -0 rmdir --ignore-fail-on-non-empty
$run $el sh -c "rm -rf \
$ROOT/dev \
$ROOT/sbin \
$ROOT/usr/lib/locale \
$ROOT/usr/lib/*glide* \
$ROOT/usr/lib/gconv \
$ROOT/usr/sbin \
$ROOT/usr/share/doc \
$ROOT/usr/share/info \
$ROOT/usr/share/man \
$ROOT/var"

# make an image
ns=$(buildah from --arch=386 scratch)
buildah copy $ns $(buildah mount $el)$ROOT /
buildah commit --rm $el

buildah config --workingdir /root $ns
buildah config --cmd /usr/bin/netscape $ns
buildah commit --rm $ns netscape

buildah rm -a
