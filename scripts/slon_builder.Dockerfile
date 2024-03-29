# This is the build stage for Polkadot. Here we create the binary in a temporary image.
FROM docker.io/paritytech/ci-linux:production as builder

WORKDIR /polkadot
COPY . /polkadot

RUN cargo build --locked --release

# This is the 2nd stage: a very small image where we copy the Polkadot binary."
FROM docker.io/library/ubuntu:20.04

COPY --from=builder /polkadot/target/release/node-template /usr/local/bin/polkadot

RUN useradd -m -u 1000 -U -s /bin/sh -d /polkadot polkadot && \
	mkdir -p /data /polkadot/.local/share && \
	chown -R polkadot:polkadot /data && \
	ln -s /data /polkadot/.local/share/polkadot && \
# unclutter and minimize the attack surface
	rm -rf /usr/bin /usr/sbin && \
# check if executable works in this container
	/usr/local/bin/polkadot --version

USER polkadot

EXPOSE 30333 9933 9944 9615
VOLUME ["/data"]

ENTRYPOINT ["/usr/local/bin/polkadot"]