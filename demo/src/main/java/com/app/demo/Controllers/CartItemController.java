package com.app.demo.Controllers;

import com.app.demo.models.*;
import com.app.demo.repository.*;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequestMapping("/cart-items")
@CrossOrigin(origins = "*")
public class CartItemController {

    @Autowired
    private CartItemRepository cartItemRepository;

    @Autowired
    private CartRepository cartRepository;

    @Autowired
    private MenuItemRepository menuItemRepository;

    @Autowired
    private CustomerRepository customerRepository;

    public static class AddCartItemRequest {
        public Long customerId;
        public Long menuItemId;
        public int quantity;
    }

    @PostMapping
    public ResponseEntity<?> addCartItem(@RequestBody AddCartItemRequest request) {
        if (request.quantity <= 0) {
            return ResponseEntity.badRequest().body("Quantity must be greater than zero");
        }

        Optional<Customer> customerOpt = customerRepository.findById(request.customerId);
        if (!customerOpt.isPresent()) {
            return ResponseEntity.badRequest().body("Customer not found");
        }
        Customer customer = customerOpt.get();

        Cart cart = customer.getCart();
        if (cart == null) {
            cart = new Cart();
            cartRepository.save(cart);
            customer.setCart(cart);
            customerRepository.save(customer);
        }

        Optional<MenuItem> menuItemOpt = menuItemRepository.findById(request.menuItemId);
        if (!menuItemOpt.isPresent()) {
            return ResponseEntity.badRequest().body("MenuItem not found");
        }
        MenuItem menuItem = menuItemOpt.get();

        CartItem existingCartItem = null;
        if (cart.getCartItems() != null) {
            for (CartItem ci : cart.getCartItems()) {
                if (ci.getMenuItem().getId()==(menuItem.getId())) {
                    existingCartItem = ci;
                    break;
                }
            }
        }

        if (existingCartItem != null) {
            int newQuantity = existingCartItem.getQuantity() + request.quantity;
            existingCartItem.setQuantity(newQuantity);
            existingCartItem.setTotalPrice(menuItem.getPrice() * newQuantity);
            cartItemRepository.save(existingCartItem);
        } else {
            CartItem cartItem = new CartItem();
            cartItem.setCart(cart);
            cartItem.setMenuItem(menuItem);
            cartItem.setQuantity(request.quantity);
            cartItem.setTotalPrice(menuItem.getPrice() * request.quantity);

            cartItemRepository.save(cartItem);

            if (cart.getCartItems() == null) {
                cart.setCartItems(new java.util.ArrayList<>());
            }
            cart.getCartItems().add(cartItem);
            cartRepository.save(cart);
        }

        return ResponseEntity.ok("Cart updated successfully");
    }


    @DeleteMapping("/{cartItemId}")
    public ResponseEntity<?> removeCartItem(@PathVariable Long cartItemId) {
        Optional<CartItem> cartItemOpt = cartItemRepository.findById(cartItemId);
        if (!cartItemOpt.isPresent()) {
            return ResponseEntity.badRequest().body("CartItem not found");
        }

        CartItem cartItem = cartItemOpt.get();
        Cart cart = cartItem.getCart();

        if (cart != null && cart.getCartItems() != null) {
            cart.getCartItems().removeIf(ci -> ci.getId().equals(cartItemId));
            cartRepository.save(cart);
        }

        cartItemRepository.delete(cartItem);

        return ResponseEntity.ok("CartItem removed successfully");
    }
}
