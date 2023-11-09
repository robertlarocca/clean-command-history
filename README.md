# clean-command-history

Removes history files created using the GNU History Library.

## Install

Install the `clean` command using:

```shell
sudo bash INSTALL
```

## Usage

Display `clean` command help:

```shell
clean --help
```

## Helpful

The following bash alias when added to your shell environment will greatly improve this scripts functionality. The alias will allow you to remove (aka clean) using whatever any option, but then also clear shell `history` using the BASH builtin afterward.

Using `nano` or `vi` edit `$HOME/.bash_aliases` to include:

```shell
alias clean="$(which clean) $* && history -c"
```
