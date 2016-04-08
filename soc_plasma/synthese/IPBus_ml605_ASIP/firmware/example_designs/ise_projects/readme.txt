It is strongly recommended that the ISE project be held in a working directory outside the repository.

The following instructions work with ISE 13.1.

- Copy the example design directory to a location outside the repository

  cp -r firmware/example_designs/ise_projects/my_project ./
  cd my_project

- Make a symbolic link from the project directory to your local copy of the firmware repository

  ln -s ../firmware

- Run the setup script to copy .xco files from the repository. Do not run coregen on .xco files in
the repository, as it will populate your working copy with many additional output files.

  ./setup_ipcore_dir.sh

- Launch ISE GUI and open the .xise project file. Ignore messages about missing IP cores.

- Start the core generator GUI.

- Double check that coregen has the correct part settings (doesn't always work), and select 'Project' ->
'Regenerate all project IP'. Wait a while.

- Exit coregen GUI. You should now be able to synthesise and implement the project
