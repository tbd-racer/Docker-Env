import argparse, os, platform
from host_functions import docker_build_image, get_git_revision_short_hash


def main() -> None:
    parser = argparse.ArgumentParser(
        "build_image", description="builds the intended docker image"
    )
    parser.add_argument(
        "type", choices=["develop", "deploy"], help="Image type to build"
    )
    parser.add_argument(
        "-c", "--clean", action="store_true", help="Force the build to a clean state"
    )
    parser.add_argument(
        "-p",
        "--push",
        action="store_true",
        help="Have docker push the image as a final step",
    )

    # default settings for the deploy build
    settings = {
        "local_arch": platform.machine(),
        "git_hash": get_git_revision_short_hash(),
        "cuda_arch": "arm64",
        "docker_arch": "linux/arm64",
        "distro": "ubuntu2204",
        "img_name_base": "coalman321/tbd-racer-{}",
        "file": "",
        "tags": [],
    }

    # Parse the args and set common settings
    args = parser.parse_args()
    if args.type == "develop":
        # Arch speicifc settings
        if settings["local_arch"] == "aarch64" or "arm" in settings["local_arch"]:
            settings["cuda_arch"] = "arm64"
            settings["docker_arch"] = "linux/arm64"
        else:
            settings["cuda_arch"] = "x86_64"
            settings["docker_arch"] = "linux/amd64"

        # generic development settings
        settings["file"] = os.path.join("dockerfiles", "tbd-racer-develop.dockerfile")
        settings["tags"] = [
            "latest-{}".format(settings["docker_arch"].split("/")[-1]),
            "{}-{}".format(
                settings["git_hash"], settings["docker_arch"].split("/")[-1]
            ),
        ]

    elif args.type == "deploy":
        settings["file"] = os.path.join("dockerfiles", "tbd-racer-deploy.dockerfile")
        settings["cuda_arch"] = "arm64"
        settings["docker_arch"] = "linux/arm64"
        settings["tags"] = ["latest", settings["git_hash"]]

    else:
        print(f"Uknown build type {args.type}")

    image_name = settings["img_name_base"].format(args.type)
    print(f"Building docker.io/{image_name}")

    # build the docker image
    docker_build_image(
        "docker.io",
        image_name,
        settings["tags"],
        settings["docker_arch"],
        args.clean,
        args.push,
        settings["file"],
    )


if __name__ == "__main__":
    main()
