.. sectnum::

Basic Linux commands
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

**AWK** - UNIX shell programming language. An fast and stable tool for processing
text files.

===================================  ==============================================================
``awk '/www/ { print $0 }' <file>``  search for the pattern 'www' in the each line of the file
``awk '$3=="www"' <file>``           search for pattern 'www' in the third column of the file
``awk 'length($0) > 80' <file>``     print every line in the file that is longer than 80 characters
``awk 'NR % 2 == 0' <file>``         print even-numbered lines in the file
===================================  ==============================================================

..

  See |awk| and |awk_tutorial| for more information

Some built-in variables
~~~~~~~~~~~~~~~~~~~~~~~

=======  ================================
``NR``   Number of records
``NF``   Number of fields
``FS``   Field separator character
``OFS``  Output field separator character
=======  ================================

Cluster basic commands
----------------------

``ssh -Y username@ant-login.linux.crg.es``  access to the cluster. The ``-Y``
option means you'll be able to open files in graphical applications.

``qsub`` batch job submission

::

  $ qsub -q course sleeper.sh

  Your job 393672 ("sleeper.sh") has been submitted

Job id: Important number that identifies your job in the cluster. It's necessary
for managing the job and control it.

``qstat`` let you monitor the status of the jobs. The -j option causes qstat to
display detailed information of a currently queued job.

``qdel`` This command let you delete a job.

::

  $ qdel Job_id

..

    See |linux_crg| for the full **CRG** cluster documentation


.. |linux_crg| raw:: html

  <a href="http://www.linux.crg.es/index.php/Main_Page" target="_blank" style='padding:0px;font-weight:bold;font-family:Monaco,Menlo,Consolas,"Courier New",monospace;'>http://www.linux.crg.es/index.php/Main_Page</a>

.. |vim| raw:: html

  <a href="http://www.howtogeek.com/102468/a-beginners-guide-to-editing-text-files-with-vi/" target="_blank" style='padding:0px;font-weight:bold;font-family:Monaco,Menlo,Consolas,"Courier New",monospace;'>a-beginners-guide-to-editing-text-files-with-vi</a>

.. |awk| raw:: html

  <a href="http://www.grymoire.com/Unix/Awk.html" target="_blank" style='padding:0px;font-weight:bold;font-family:Monaco,Menlo,Consolas,"Courier New",monospace;'>http://www.grymoire.com/Unix/Awk.html</a>

.. |awk_tutorial| raw:: html

  <a href="http://www.tutorialspoint.com/awk/awk_basic_examples.htm" target="_blank" style='padding10px;font-weight:bold;font-family:Monaco,Menlo,Consolas,"Courier New",monospace;'>http://www.tutorialspoint.com/awk/awk_basic_examples.htm</a>
