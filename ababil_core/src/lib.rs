use serde::{Deserialize, Serialize};
use std::ffi::{CStr, CString};
use std::os::raw::c_char;
use std::ptr;

#[derive(Debug, Serialize, Deserialize)]
pub struct HttpRequest {
    pub method: String,
    pub url: String,
    pub headers: Vec<(String, String)>,
    pub body: Option<String>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct HttpResponse {
    pub status_code: u16,
    pub headers: Vec<(String, String)>,
    pub body: String,
    pub duration_ms: u64,
}

#[no_mangle]
pub extern "C" fn make_http_request(
    method: *const c_char,
    url: *const c_char,
    headers_json: *const c_char,
    body: *const c_char,
) -> *mut c_char {
    let method_str = unsafe {
        if method.is_null() {
            return ptr::null_mut();
        }
        match CStr::from_ptr(method).to_str() {
            Ok(s) => s,
            Err(_) => return ptr::null_mut(),
        }
    };

    let url_str = unsafe {
        if url.is_null() {
            return ptr::null_mut();
        }
        match CStr::from_ptr(url).to_str() {
            Ok(s) => s,
            Err(_) => return ptr::null_mut(),
        }
    };

    let headers: Vec<(String, String)> = if !headers_json.is_null() {
        unsafe {
            match CStr::from_ptr(headers_json).to_str() {
                Ok(json_str) => {
                    serde_json::from_str(json_str).unwrap_or_default()
                }
                Err(_) => Vec::new(),
            }
        }
    } else {
        Vec::new()
    };

    let body_str = if !body.is_null() {
        unsafe {
            match CStr::from_ptr(body).to_str() {
                Ok(s) => Some(s.to_string()),
                Err(_) => None,
            }
        }
    } else {
        None
    };

    let start = std::time::Instant::now();
    let response_result = execute_request(method_str, url_str, &headers, body_str.as_deref());
    
    let response = match response_result {
        Ok(resp) => resp,
        Err(e) => HttpResponse {
            status_code: 0,
            headers: Vec::new(),
            body: format!("Error: {}", e),
            duration_ms: start.elapsed().as_millis() as u64,
        },
    };

    let duration_ms = start.elapsed().as_millis() as u64;
    let final_response = HttpResponse {
        duration_ms,
        ..response
    };

    match serde_json::to_string(&final_response) {
        Ok(json) => CString::new(json).unwrap().into_raw(),
        Err(_) => ptr::null_mut(),
    }
}

fn execute_request(
    method: &str,
    url: &str,
    headers: &[(String, String)],
    body: Option<&str>,
) -> Result<HttpResponse, Box<dyn std::error::Error>> {
    let rt = tokio::runtime::Runtime::new()?;
    rt.block_on(async {
        let client = reqwest::Client::new();
        let method_upper = method.to_uppercase();
        let mut request_builder = match method_upper.as_str() {
            "GET" => client.get(url),
            "POST" => client.post(url),
            "PUT" => client.put(url),
            "PATCH" => client.patch(url),
            "DELETE" => client.delete(url),
            "HEAD" => client.head(url),
            "OPTIONS" => client.request(reqwest::Method::OPTIONS, url),
            _ => return Err("Unsupported HTTP method".into()),
        };

        for (key, value) in headers {
            request_builder = request_builder.header(key, value);
        }

        if let Some(body_str) = body {
            request_builder = request_builder.body(body_str.to_string());
        }

        let response = request_builder.send().await?;
        let status_code = response.status().as_u16();
        let response_headers: Vec<(String, String)> = response
            .headers()
            .iter()
            .map(|(k, v): (&reqwest::header::HeaderName, &reqwest::header::HeaderValue)| {
                (
                    k.to_string(),
                    v.to_str().unwrap_or("").to_string(),
                )
            })
            .collect();

        let body_text = response.text().await?;

        Ok(HttpResponse {
            status_code,
            headers: response_headers,
            body: body_text,
            duration_ms: 0, // Will be set by caller
        })
    })
}

#[no_mangle]
pub extern "C" fn free_string(ptr: *mut c_char) {
    if !ptr.is_null() {
        unsafe {
            let _ = CString::from_raw(ptr);
        }
    }
}

