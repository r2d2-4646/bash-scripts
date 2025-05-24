t DNS and network connectivity
echo "=== Network Connectivity Tests ==="
echo "1. Basic ping test"
echo "2. DNS resolution test"
echo "3. HTTP connectivity test"
echo "4. Full diagnostic"
echo "Enter choice (1-4): "
read choice

case $choice in
	    1)
		            echo "Enter host/IP to ping: "
			            read host
				            ping -c 4 $host
					            ;;
						        2)
								        echo "Enter domain to resolve: "
									        read domain
										        dig $domain +short
											        echo "Using DNS servers:"
												        grep nameserver /etc/resolv.conf
													        ;;
														    3)
															            echo "Enter URL to test (without https://): "
																            read url
																	            curl -I "https://$url" || curl -I "http://$url"
																		            ;;
																			        4)
																					        echo "=== Running full diagnostic ==="
																						        echo "IP Address: $(hostname -I)"
																							        echo "Routing Table:"
																								        ip route
																									        echo -e "\nPinging 8.8.8.8 (Google DNS):"
																										        ping -c 4 8.8.8.8
																											        echo -e "\nTesting DNS resolution (google.com):"
																												        dig google.com +short
																													        echo -e "\nTesting HTTP connection:"
																														        curl -I https://ubuntu.com
																															        ;;
																																    *) echo "Invalid choice!" ;;
																															    esac
