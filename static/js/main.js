// Main JavaScript for Flask E-Commerce

document.addEventListener('DOMContentLoaded', function() {
    // Initialize tooltips
    var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
        return new bootstrap.Tooltip(tooltipTriggerEl);
    });

    // Add loading state to buttons
    const buttons = document.querySelectorAll('.btn[type="submit"]');
    buttons.forEach(button => {
        button.addEventListener('click', function(e) {
            const form = this.closest('form');
            if (form && form.checkValidity()) {
                addLoadingState(this);
            }
        });
    });

    // Cart quantity updates
    const quantityInputs = document.querySelectorAll('.quantity-input');
    quantityInputs.forEach(input => {
        input.addEventListener('change', function() {
            updateCartQuantity(this);
        });
    });

    // Product image lazy loading
    const images = document.querySelectorAll('img[data-src]');
    const imageObserver = new IntersectionObserver((entries, observer) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const img = entry.target;
                img.src = img.dataset.src;
                img.classList.remove('lazy');
                imageObserver.unobserve(img);
            }
        });
    });

    images.forEach(img => imageObserver.observe(img));

    // Form validation
    const forms = document.querySelectorAll('.needs-validation');
    forms.forEach(form => {
        form.addEventListener('submit', function(event) {
            if (!form.checkValidity()) {
                event.preventDefault();
                event.stopPropagation();
            }
            form.classList.add('was-validated');
        });
    });

    // Search functionality
    const searchInput = document.getElementById('search');
    if (searchInput) {
        let searchTimeout;
        searchInput.addEventListener('input', function() {
            clearTimeout(searchTimeout);
            searchTimeout = setTimeout(() => {
                if (this.value.length >= 3) {
                    searchProducts(this.value);
                }
            }, 300);
        });
    }

    // Add to cart animation
    const addToCartButtons = document.querySelectorAll('.add-to-cart');
    addToCartButtons.forEach(button => {
        button.addEventListener('click', function(e) {
            e.preventDefault();
            animateAddToCart(this);
            // Simulate adding to cart
            setTimeout(() => {
                window.location.href = this.href;
            }, 800);
        });
    });

    // Auto-hide alerts
    const alerts = document.querySelectorAll('.alert');
    alerts.forEach(alert => {
        setTimeout(() => {
            if (alert) {
                const bsAlert = new bootstrap.Alert(alert);
                bsAlert.close();
            }
        }, 5000);
    });
});

// Helper functions
function addLoadingState(button) {
    const originalText = button.innerHTML;
    button.innerHTML = '<span class="spinner-border spinner-border-sm me-2" role="status"></span>Loading...';
    button.disabled = true;
    
    // Restore original state after form submission or timeout
    setTimeout(() => {
        button.innerHTML = originalText;
        button.disabled = false;
    }, 3000);
}

function updateCartQuantity(input) {
    const productId = input.dataset.productId;
    const quantity = input.value;
    
    // Show loading state
    input.parentElement.classList.add('loading');
    
    // Simulate API call
    fetch(`/api/update-cart/${productId}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-Requested-With': 'XMLHttpRequest'
        },
        body: JSON.stringify({ quantity: quantity })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            updateCartTotal(data.new_total);
            showNotification('Cart updated successfully', 'success');
        } else {
            showNotification('Error updating cart', 'error');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        showNotification('Error updating cart', 'error');
    })
    .finally(() => {
        input.parentElement.classList.remove('loading');
    });
}

function updateCartTotal(newTotal) {
    const totalElements = document.querySelectorAll('.cart-total');
    totalElements.forEach(element => {
        element.textContent = `$${newTotal.toFixed(2)}`;
    });
}

function animateAddToCart(button) {
    const originalText = button.innerHTML;
    button.innerHTML = '<i class="fas fa-check me-1"></i>Added!';
    button.classList.remove('btn-primary');
    button.classList.add('btn-success');
    
    setTimeout(() => {
        button.innerHTML = originalText;
        button.classList.remove('btn-success');
        button.classList.add('btn-primary');
    }, 1000);
}

function searchProducts(query) {
    const resultsContainer = document.getElementById('search-results');
    if (!resultsContainer) return;
    
    fetch(`/api/search?q=${encodeURIComponent(query)}`)
    .then(response => response.json())
    .then(data => {
        displaySearchResults(data.products, resultsContainer);
    })
    .catch(error => {
        console.error('Search error:', error);
    });
}

function displaySearchResults(products, container) {
    if (products.length === 0) {
        container.innerHTML = '<p class="text-muted">No products found</p>';
        return;
    }
    
    const html = products.map(product => `
        <div class="search-result-item p-2 border-bottom">
            <a href="/product/${product.id}" class="text-decoration-none">
                <div class="d-flex align-items-center">
                    <div class="me-3">
                        <i class="fas fa-image fa-2x text-muted"></i>
                    </div>
                    <div>
                        <h6 class="mb-1">${product.name}</h6>
                        <p class="mb-0 text-muted small">${product.description.substring(0, 100)}...</p>
                        <span class="text-primary">$${product.price.toFixed(2)}</span>
                    </div>
                </div>
            </a>
        </div>
    `).join('');
    
    container.innerHTML = html;
}

function showNotification(message, type = 'info') {
    const alertClass = type === 'success' ? 'alert-success' : 
                      type === 'error' ? 'alert-danger' : 
                      type === 'warning' ? 'alert-warning' : 'alert-info';
    
    const alertHtml = `
        <div class="alert ${alertClass} alert-dismissible fade show" role="alert">
            ${message}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    `;
    
    const container = document.querySelector('.container');
    if (container) {
        container.insertAdjacentHTML('afterbegin', alertHtml);
        
        // Auto-hide after 3 seconds
        setTimeout(() => {
            const alert = container.querySelector('.alert');
            if (alert) {
                const bsAlert = new bootstrap.Alert(alert);
                bsAlert.close();
            }
        }, 3000);
    }
}

// Utility functions for form handling
function validateEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
}

function validatePhone(phone) {
    const phoneRegex = /^\(\d{3}\)\s\d{3}-\d{4}$/;
    return phoneRegex.test(phone);
}

function formatCurrency(amount) {
    return new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: 'USD'
    }).format(amount);
}

// Export functions for use in other scripts
window.ECommerceApp = {
    addLoadingState,
    updateCartQuantity,
    animateAddToCart,
    showNotification,
    validateEmail,
    validatePhone,
    formatCurrency
};
