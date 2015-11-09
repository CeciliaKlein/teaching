.. sectnum::

CRG RNAseq course cheatsheet
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Basic Linux Commands
====================

.. image:: assets/crg_blue_logo.jpg
    :height: 160px
    :width: 350px
    :scale: 50 %
    :align: right
    :alt: CRG Barcelona

Browse the directory structure
------------------------------

==========================  =====================================================
``pwd``                     tells you where you are
``ls``                      list the content of the current directory
``ls <directory name>``     list the content of a directory
``cd <directory name>``     go to the specified directory
``cd  ~`` (or ``cd``)       go to your home directory
``cd  ..``                  go to the parent directory
``tree <directory name>``   list the content of a directory in a tree-like format
``mkdir <directory name>``  creates specified directory
==========================  =====================================================

View the content of a file
--------------------------

==================  ===========================================
``less``, ``more``  view text with paging
``head``            prints first lines of a file
``tail``            prints last lines of a file
``cat``             print content of a file into the screen
``zcat``            print content of a ``gzip`` compressed file
==================  ===========================================

File manipulations
------------------

======================  =====================
``rm <file name>``      remove file
``cp <file1> <file2>``  copy file1 into file2
``mv <file1> <file2>``  rename file1 to file2
======================  =====================

File editing
------------

================  ===================================================
``gedit <file>``  text editor with graphical user interface
``vi <file>``     text editor with command mode interface (See |vim|)
================  ===================================================

Some other useful commands
--------------------------

==========================  ======================================================
``grep <pattern>``          show lines of text containing a given pattern
``grep -v <pattern>``       show lines of text not containing a given pattern
``sort``                    sort linesof text files
``wc``                      counting words, lines and characters
``>`` (output redirection)  allows to redirect the output to a file
``|`` (pipe)                allows to send output from one program to another
``cut``                     to extract portion of a file by selecting columns
``echo``                    input a line of text and display it on standard output
==========================  ======================================================

AWK programming
---------------

**AWK** - UNIX shell programming language. A fast and stable tool for processing
text files.

===================================  ==============================================================
``awk '/www/ { print $0 }' <file>``  search for the pattern 'www' in the each line of the file
``awk '$3=="www"' <file>``           search for pattern 'www' in the third column of the file
``awk 'length($0) > 80' <file>``     print every line in the file that is longer than 80 characters
``awk 'NR % 2 == 0' <file>``         print even-numbered lines in the file
===================================  ==============================================================

Some built-in variables
:::::::::::::::::::::::

=======  ================================
``NR``   Number of records
``NF``   Number of fields
``FS``   Field separator character
``OFS``  Output field separator character
=======  ================================

..

  See |awk| and |awk_tutorial| for more information

Basic Cluster Commands
======================

==========================================  ========================================
``ssh -Y username@ant-login.linux.crg.es``  access to the cluster - ``-Y`` allows
                                            graphical output (**X11** forwarding)
``qsub -q <queue> <script>``                submit a batch job to a specific queue
``qstat``                                   monitor the status of submitted jobs
``qstat -j <job_id>``                       display detailed information of a specific
                                            job
``qdel <job_id>``                           delete a submitted job
==========================================  ========================================

The ``job_id`` is an important number that identifies your job in the cluster. It's
necessary for managing the job and control it.

A simple example of job submission and deletion::

  $ qsub -q course sleeper.sh
  Your job 393672 ("sleeper.sh") has been submitted

  $ qstat
  job-ID     prior   name       user         state submit/start at     queue            jclass             slots ja-task-ID
  -------------------------------------------------------------------------------------------------------------------------
    393672   0.00000 sleeper.sh epalumbo     qw    11/09/2015 11:18:01                                         1

  $ qdel 393672
  epalumbo has deleted job 393672

..

    See |linux_crg| for the complete **CRG** cluster documentation


.. |linux_crg| raw:: html

  <a href="http://www.linux.crg.es/" target="_blank" style='padding:0px;font-weight:bold;font-family:Monaco,Menlo,Consolas,"Courier New",monospace;'>http://www.linux.crg.es</a>

.. |vim| raw:: html

  <a href="http://www.howtogeek.com/102468/a-beginners-guide-to-editing-text-files-with-vi/" target="_blank" style='padding:0px;font-weight:bold;font-family:Monaco,Menlo,Consolas,"Courier New",monospace;'>a-beginners-guide-to-editing-text-files-with-vi</a>

.. |awk| raw:: html

  <a href="http://www.grymoire.com/Unix/Awk.html" target="_blank" style='padding:0px;font-weight:bold;font-family:Monaco,Menlo,Consolas,"Courier New",monospace;'>http://www.grymoire.com/Unix/Awk.html</a>

.. |awk_tutorial| raw:: html

  <a href="http://www.tutorialspoint.com/awk/awk_basic_examples.htm" target="_blank" style='padding10px;font-weight:bold;font-family:Monaco,Menlo,Consolas,"Courier New",monospace;'>http://www.tutorialspoint.com/awk/awk_basic_examples.htm</a>
