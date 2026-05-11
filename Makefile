.PHONY: backup

backup:
	rsync -av                   \
		rmk:/home/root/.local/  \
		./ssh-data/.local/
	rsync -av                   \
		rmk:/home/root/.config/ \
		./ssh-data/.config/
	rsync -av                   \
		rmk:/home/root/log.txt \
		./ssh-data/log.txt
