use std::error::Error;
use std::net::SocketAddr;
use std::net::{IpAddr, Ipv4Addr};

use log::{debug, info};
use socket2::{Domain, Protocol, Socket, Type};
use tokio::net::TcpSocket;
use windivert::{CloseAction, WinDivert};
use windivert::prelude::WinDivertFlags;

type DynResult<T> = Result<T, Box<dyn Error + Sync + Send>>;


async fn test_internet_access(number: usize, address: Ipv4Addr, port: u16, local: Option<Ipv4Addr>) {
    debug!("TEST BLOCK {number} STARTED");
    let peer_address = SocketAddr::new(IpAddr::V4(address), port);
    let socket = Socket::new(Domain::IPV4, Type::STREAM, Some(Protocol::TCP))?.into();
    let connection_socket = TcpSocket::from_std_stream(socket);

    if let Some(addr) = local {
        let local_address = SocketAddr::new(IpAddr::V4(addr), 0);
        debug!("Binding connection client to {}...", local_address);
        connection_socket.bind(local_address)?;
    }

    debug!("Connecting to listener at {}", peer_address);
    let connection_stream = connection_socket.connect(peer_address).await?;
    debug!("Current user address: {}", connection_stream.local_addr()?);
    debug!("TEST BLOCK {number} ENDED");
}


#[tokio::main]
async fn main() -> DynResult<()> {
    let test_ip = Ipv4Addr::new(8, 8, 4, 4);
    let test_port = 80;

    info!("Testing internet connection without WinDivert...");
    test_internet_access(1, test_ip, test_port, None).await;

    let filter = format!("false");  // Add any filter string here
    debug!("WinDivert filter will be used: '{filter}'");
    let divert = WinDivert::network(filter, 0, WinDivertFlags::new())?;

    info!("Testing internet connection with WinDivert...");
    test_internet_access(2, test_ip, test_port, None).await;

    debug!("Closing WinDivert...");
    divert.close(CloseAction::Nothing)?;
    Ok(())
}
