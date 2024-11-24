## Ansible Users

An Ansible role for creating users, groups and doing various modifications related to them.

### Values

All values are optional unless otherwise marked as required:

```yaml
identities:
	root:
		login: bool 											<indicates if root login should be possible. Done as last task in case of failure>
	groups:
		- id: integer
			name: String										<required if groups array is defined and has values>
			state: [ absent, present ]
	users:
		- id: integer
			name: String										<required if users array is defined and has values>
			comment: String
			password:
				value: String
				policy: [ 
					always											<sets the value as password each time>
					on_create 									<only sets the value as password when creating user>
				]
			group:
				id: integer
				name: String									<required if group object is defined, otherwise user.name is used>
			groups: String array
			shell: String
			home:
				state: [
					absent,											<will remove the users home directory>
					present											<will create a home directory for user>
				],
				mode: String									<chmod value for the directory>
			state: [
				absent,												<will remove the user, group, home dir, sudoer file and ssh keys>
				present												<will create the user if not already present - DEFAULT choice>
			]
			sudoer:
				state: [
					absent,											<will remove the user's sudoer file>
					present											<will create, copy or modify the suoder file - DEFAULT choice if sudoer exists>
				]
				privileges: String						<The privilege line to set to the sudoer file - required or file>
				file:	String									<path to file to copy over as the sudoer file - required or privileges>
			ssh:
				authorized:
					- key: String								<the public ssh key>
						state: [
							absent,									<will remove the key from authorized keys if found>
							present									<will add the key to the authorized keys if missing>
						]
```

#### Example:

```yaml
identities:
	root:
		login: false
	groups:
		- id: 4324
			name: æsir
			state: absent
		- id: 6546
			name: vanir
		- id: 9001
			name: gods
	users:
		- id: 7474
			name: Freyja
			comment: "Godess of home and hearth"
			password:
				value: $6$pnrja6mdaIDRT8jY$ZXUTacmWsztweowb3NIjS95EhIlfLv4OwncWtHK0AubenlLExhKTeuf/B/FQK4PX0mIzHdhwSoJNssbrndacU/
				policy: always
			groups:
				- vanir
				- gods
				- sudo
			shell: /bin/fish
			home:
				mode: 0777 #Only Freyja should do this!
			sudoer:
				privileges: "ALL=(ALL) NOPASSWD: ALL"
			ssh:
				authorized:
					- key: ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPJLon4ATM0Bb6CbQPkOs1UnobDtUATfzCZ+MWcO8Q54 freyja
					- key: ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPQwZJNnlC8YzLEpEGDTizfH18kJ2UHXZkFrfOpDXsxP odinn
						state: absent
```