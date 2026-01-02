;; Agent-Zero System Configuration Template
;; /config/agent-zero-system.scm

(use-modules (gnu)
             (gnu system)
             (gnu services)
             (gnu packages)
             (agent-zero packages cognitive))

(operating-system
  (host-name "agent-zero")
  (timezone "UTC")
  (locale "en_US.utf8")
  
  ;; Basic system configuration
  (bootloader (bootloader-configuration
               (bootloader grub-bootloader)
               (target "/dev/sda")))
  
  (file-systems (cons (file-system
                        (device (file-system-label "root"))
                        (mount-point "/")
                        (type "ext4"))
                      %base-file-systems))
  
  ;; Agent-Zero specific services
  (services
    (append
      %base-services
      (list (extra-special-file "/etc/agent-zero.conf"
                                (plain-file "agent-zero.conf"
                                           "# Agent-Zero Configuration\n")))))
  
  ;; Agent-Zero cognitive packages
  (packages
    (append %base-packages
            (list opencog
                  ggml
                  guile-pln
                  guile-ecan
                  guile-moses
                  guile-pattern-matcher
                  guile-relex))))
