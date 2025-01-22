## Ansible Identities

An Ansible role for creating users, groups and doing various modifications related to them.

### Values

All values are optional unless otherwise marked as required:

```yaml
identities:
  root:
    login: bool       <indicates if root login should be possible. Done as last task in case of failure>
  groups:
    - id: integer
      name: String    <required if groups array is defined and has values>
      state: [ absent, present ]
  users:
  - id: integer
    name: String      <required if users array is defined and has values>
    comment: String
    password:
      value: String   The direct value to set the password to. See password section below for more.
      variable: String  The Ansible run variable to read the password from. See password section below for more.
      policy: [ 
        always        <sets the value as password each time>
        on_create     <only sets the value as password when creating user>
      ]
    group:
      id: integer
      name: String    <required if group object is defined, otherwise user.name is used>
    groups: String array
    shell: String
    home:
      state: [
        absent,       <will remove the users home directory>
        present       <will create a home directory for user>
      ],
      mode: String    <chmod value for the directory>
      dirs:
        - path: string/array    [required] Either a singular value or an array, representing the dir path in relation to the user's home directory to where the directory should be created.
          remove: bool    Indicates if the path should be removed. Default false.
          force: bool     Indicates if the path should be forcefully modified if it already exists. Default false.
          mode: string    The access control to set on the directory. Default '0755'.
      files:
        - source: string  [required] The path to the source file to copy over.
          path: string    [required] The path in relation to the user's home directory to where the file should be copied to
          remove: bool    Indicates if the path should be removed
          force: bool     Indicates if the path should be forcefully modified if it already exists. Default false.
          backup: bool    Indicates if any current file at the same [path] should be backed up in place. Default false.
          mode: string    The access control to set on the file. Default '0744'.
      templates:
        - source: string  [required] The path to the source template.
          path: string    [required] The path in relation to the user's home directory to where the template file should be created.
          force: bool     Indicates if the path should be forcefully modified if it already exists. Default false.
          backup: bool    Indicates if any current file at the same [path] should be backed up in place. Default false.
          mode: string    The access control to set on the file. Default '0744'.
    state: [
       absent,        <will remove the user, group, home dir, sudoer file and ssh keys>
       present        <will create the user if not already present - DEFAULT choice>
    ]
    sudoer:
      state: [
        absent,				<will remove the user's sudoer file>
        present				<will create, copy or modify the suoder file - DEFAULT choice if sudoer exists>
      ]
      privileges: String			<The privilege line to set to the sudoer file - required or file>
      file:	String			<path to file to copy over as the sudoer file - required or privileges>
    ssh:
      authorized:
        - key: String			<the public ssh key>
          state: [
            absent,			<will remove the key from authorized keys if found>
            present			<will add the key to the authorized keys if missing>
          ]
```

##### Password

When setting the password for a user, it is possible to include the password directly in the `value` field or by using the `variable` field to look it up form variables in the Ansible run. This can be beneficial when not wanting to expose password hashes directly in the playbook, and rather have the value be read into a variable (for instance from a Vault) at runtime. If neither `variable` nor `value` is present, the user will receive a password (i.e '!') and not be able to log in.

#### Example:

```yaml
identities:
  root:
    login: false
  groups:
  - id: 1234
    name: æsir
    state: absent
  - name: vanir
  users:
  - id: 6666
    name: Loki
    password:
      variable: super_secret_password
  - id: 7777
    name: Freyja
    comment: "Godess of home and hearth"
    password:
      value: "$6$pnrja6mdaIDRT8jY$ZXUTacmWsztweowb3NIjS95EhIlfLv4OwncWtHK0AubenlLExhKTeuf/B/FQK4PX0mIzHdhwSoJNssbrndacU/"
      policy: always
    groups:
    - vanir
    - gods
    - sudo
    shell: "/bin/fish"
    home:
      mode: "0777" # Only Freyja should do this!
      dirs:
        - mode: "2777" # Only Freyja should do this!
          path:
            - 'recipes'
            - 'farming/tips'
        - mode: "0700"
          path: '.spells'
        - path: 'flora/mistletoe'
          remove: true
      files:
        - source: "recipes/fish/"
          path: "recipes"
          mode: "0777"
      templates:
        - source: "templates/magic/spells/love-potion.j2"
          path: ".spells/love-potion"
          mode: "0700"
          vars:
            key_ingredient: "blood of inocents"
    sudoer:
      privileges: "ALL=(ALL) NOPASSWD: ALL"
    ssh:
      authorized:
      - key: ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPJLon4ATM0Bb6CbQPkOs1UnobDtUATfzCZ+MWcO8Q54 freyja
      - key: ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPQwZJNnlC8YzLEpEGDTizfH18kJ2UHXZkFrfOpDXsxP odinn
        state: absen
```
