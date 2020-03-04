# Dmzj toolkit

Fast usage

1. Get id of a manga:
   
   ```bash
   getid.sh https://manhua.dmzj.com/shiguangsuipian
   ```

*or*

```bash
getid.sh -s shiguangsuipian
```

2. Get info of a manga:
   
   ```bash
   dmzj.down.sh -i 18473 -l
   ```

*or*

```bash
dmzj.down.sh -i 18473 -j
```

3. Download a comics

```bash
dmzj.down.sh -i 18473 -I 88659 87663 ...
```

*or*

```bash
dmzj.down.sh -i 18473 -I all
```

## Report BUGS?

It's nice of you to report bugs you've met. If you want to report a bug, please run the following command

```bash
(date && bash -xv dmzj.down.sh -i 1234 -l 2>&1 )  > report
```

and put the output of report to the issues on github. Thank you!
