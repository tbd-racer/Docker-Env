import argparse, os, platform
from host_functions import docker_build_image, get_git_revision_short_hash


def main() -> None:
    parser = argparse.ArgumentParser(
        "build_image", description="builds the intended docker image"
    )
    parser.add_argument(
        "type", choices=["develop", "deploy"], help="Image type to build"
    )
    parser.add_argument("-c", "--clean", action="store_true", help="Force the build to a clean state")
    parser.add_argument("-p", "--push", action="store_true", help="Have docker push the image as a final step")

    # get the working directory
    work_path = os.path.dirname(os.path.realpath(__file__))
    workdir = os.path.split(work_path)[-1].lower()

    # default settings for the deploy build
    settings = {
        "local_arch": platform.machine(),
        "git_hash": get_git_revision_short_hash(),
        "cuda_arch": "arm64",
        "docker_arch": "arm64v8",
        "distro": "ubuntu2204",
        "base_img": "dustynv/cudnn:8.9-r36.2.0",
        "img_name_base": "coalman321/tbd-racer-{}",
        "file": "",
    }

    # Parse the args and set common settings
    args = parser.parse_args()
    if args.type == "develop":
        # generic development settings
        settings["base_image"] = "nvidia/cuda:12.2.2-devel-ubuntu22.04"
        settings["file"] = os.path.join("dockerfiles", "tbd-racer-devel.dockerfile")

        # Arch speicifc settings
        if settings["local_arch"] == "aarch64" or "arm" in settings["local_arch"]:
            settings["cuda_arch"] = "arm64"
            settings["docker_arch"] = "linux/arm64"
        else:
            settings["cuda_arch"] = "x86_64"
            settings["docker_arch"] = "linux/amd64"

    elif args.type == "deploy":
        settings["base_img"] = "dustynv/cudnn:8.9-r36.2.0"
        settings["file"] = os.path.join("dockerfiles", "tbd-racer-deploy.dockerfile")
        settings["cuda_arch"] = "arm64"
        settings["docker_arch"] = "linux/arm64"

    else:
        print(f"Uknown build type {args.type}")

        # build the docker image
    docker_build_image(
        "docker.io",
        settings["img_name_base"].format(args.type),
        ["latest", settings["git_hash"]],
        settings["docker_arch"],
        args.clean,
        args.push,
        settings["file"],
        [f"BASE_IMG={settings['base_img']}"],
    )


if __name__ == "__main__":
    main()
